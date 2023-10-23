import pytest
from pymtl3 import *
from pymtl3.passes.backends.verilog import *
from pymtl3.stdlib.test_utils import run_sim
from pymtl3.stdlib import stream
from fixedpt import CFixed
from src.fixed_point.combinational.harnesses.butterfly import HarnessVRTL
from src.fixed_point.combinational.tests.complex_multiplier import cmul
import random
from tools.pymtl_extensions import mk_packed
from src.fixed_point.tools.params import rand_fxp_spec


# Performs the butterfly operation on two complex numbers
# Used to generate the expected output
def butterfly(n, d, a, b, w):
    t = cmul(n, d, b, w)
    return ((a + t).resize(n, d), (a - t).resize(n, d))


# Merge inputs into a single bus
def mk_msg(n, a, b, w):
    return mk_packed(n)(*a, *b, *w)

# Merge outputs into a single bus
def mk_ret(n, c, d):
    return mk_packed(n)(*c, *d)

# Create test parametrization information
# execution_number: number of times to run the test
# sequence_lengths: numbers of inputs to stream through the block
# n: bounds on number of bits in the fixed point number
# d: bounds on number of decimal bits in the fixed point number
# bin1: the butterfly parameter (b in 1 butterfly)
def mk_params(execution_number, sequence_lengths, n, d, bin1, slow=False):
    if isinstance(n, int):
        n = (n, n)
    if isinstance(d, int):
        d = (d, d)

    res = []

    for k in bin1:
        for j in range(execution_number):
            for i in sequence_lengths:
                res.append(
                    pytest.param(
                        j,  # execution_number index (unused)
                        i,  # number of inputs to stream
                        n,  # `n` bounds
                        d,  # `d` bounds
                        k,  # k in one butterfly
                        id=f"{i} ({n[0]}-{n[1]})-bit, ({d[0]}-{d[1]})-decimal-bit numbers"
                        + (f", {k}in1 butterfly "),
                        marks=pytest.mark.slow if slow else [],
                    )
                )
    return res


# Test harness for streaming data
class Harness(Component):
    def construct(s, mult, n, b = 1):
        s.mult = mult

        s.src = stream.SourceRTL(mk_bits(6 * n * b))

        s.sink = stream.SinkRTL(mk_bits(4 * n * b))

        s.src.send //= s.mult.recv
        s.mult.send //= s.sink.recv

    def done(s):
        return s.src.done() and s.sink.done()

    def line_trace(s):
        return s.src.line_trace() + " > " + s.mult.line_trace() + " > " + s.sink.line_trace()


# Initialize a simulatable model
def create_model(n, d, b):
    model = HarnessVRTL(n, d,  b)

    return Harness(model, n, b)


# return a random fixed point value
def rand_cfixed(n, d):
    return CFixed(
        (random.randint(0, (1 << n) - 1), random.randint(0, (1 << n) - 1)),
        n,
        d,
        raw=True,
    )

@pytest.mark.parametrize(
    "n, d, a, b, w,",
    [
        (3, 0, (0, 1), (0, 1), (0, 1)),
        (2, 1, (1, 0), (1, 0), (1, 0)),
        (8, 4, (1, 1), (1, 1), (1, 1)),
        (8, 4, (0.5, 0.5), (0.5, 0.5), (1, 0)),
        (6, 3, (3, 3), (3, 3), (1, 0)),  # overflow check
    ],
)
def test_edge(n, d, a, b, w):
    a = CFixed(a, n, d)
    b = CFixed(b, n, d)
    w = CFixed(w, n, d)

    model = create_model(n, d, b=1)

    msg = []
    msg.append(mk_msg(n, a.get(), b.get(), w.get()))

    model.set_param(
        "top.src.construct",
        msgs=msg,
        initial_delay=0,
        interval_delay=0,
    )

    (c1, d1) = butterfly(n, d, a, b, w)

    ret = []
    ret.append(mk_ret(n, c1.get(), d1.get()))

    model.set_param(
        "top.sink.construct",
        msgs=ret,
        initial_delay=0,
        interval_delay=0,
    )

    run_sim(
        model,
        cmdline_opts={"dump_textwave": False, "dump_vcd": "edge", "max_cycles": None},
    )

    # out = Fixed(int(eval_until_ready(model, a, b)), s, n, d, raw=True)

    # c = (a * b).resize(s, n, d)
    # print("%s * %s = %s, got %s" % (a.bin(dot=True), b.bin(dot=True), c.bin(dot=True), out.bin(dot=True)))
    # assert c.bin() == out.bin()

def concat_Bits(list, n):
    res = list[0]
    for i in range(1, len(list)):
        res = concat(res, list[i])
    return res

@pytest.mark.parametrize(
    "execution_number, sequence_length, n, d, bin1",
    # Runs tests on smaller number sizes
    mk_params(50, [1, 50], (2, 8), (0,8), bin1=[1,2,4,8], slow=True) +
    # Runs tests on 20 randomly sized fixed point numbers, inputting 1, 5, and 50 numbers to the stream
    mk_params(20, [1, 100], (16, 64), (0,64), bin1=[1,2,4,8], slow=True) +
    # Extensively tests numbers with certain important bit sizes.
    sum(
        [
            [
                *mk_params(1, [20], n, d, [1,2,4,8,16,32], slow=False),
                *mk_params(1, [1000], n, d, [1,2,4,8,16,32], slow=True),
            ]
            for (n, d) in [
                (8, 4),
                (24, 8),
                (32, 24),
                (32, 16),
                (64, 32),
            ]
        ],
        [],
    ),
)
def test_random(
    execution_number, sequence_length, n, d, bin1
):  # test individual and sequential multiplications to assure stream system works
    random.seed(random.random() + execution_number)
    n, d = rand_fxp_spec(n, d)
    
    dat = []
    solns = []
    for i in range(sequence_length):   
        input = []
        output = []
        for j in range(bin1):
            a = rand_cfixed(n, d)
            b = rand_cfixed(n, d)
            w = rand_cfixed(n, d)
            input.append(mk_msg(n, a.get(), b.get(), w.get()))
            c, dd = butterfly(n, d, a, b, w)
            output.append(mk_ret(n, c.get(), dd.get()))

        dat.append(concat_Bits(input, n*6))
        solns.append(concat_Bits(output, n*4))

    model = create_model(n, d, bin1)

    model.set_param("top.src.construct", msgs=dat, initial_delay=0, interval_delay=0)

    model.set_param(
        "top.sink.construct",
        msgs=solns,
        initial_delay=0,
        interval_delay=0,
    )

    run_sim(
        model,
        cmdline_opts={
            "dump_textwave": False,
            "dump_vcd": f"rand_{execution_number}_{sequence_length}_{n}_{d}_{bin1}",
            "max_cycles": (
                30 + ((n + 2) * 3 + 4) * len(dat)
            ),  # makes sure the time taken grows linearly with respect to n
        },
    )