import cocotb
from cocotb.triggers import Timer
import numpy as np


async def conv_test_gen(dut, input_arr, filter):
    dut.input_msg.value = input_arr[::-1]
    dut.filter_msg.value = filter[::-1]

    # # for _ in range(32):
    dut.clk.value = 0
    await Timer(1, units="ns")
    dut.clk.value = 1
    await Timer(1, units="ns")

    # for i in range(len(dut.input_msg.value)):
    #     dut._log.info("INPUT: %i: %s", i, dut.input_msg.value[i])
    # for i in range(len(dut.filter_msg.value)):
    #     dut._log.info("FILTER: %i: %s", i, dut.filter_msg.value[i])

    # assert that convolution has multiplied values correctly
    out = dut.output_msg.value[::-1]
    for i in range(len(out)):
        dut._log.info("OUTPUT: %i: %s", i, out[i])
    # assert (
    #     dut.output_arr_msg.value[i]
    #     == dut.input_arr_msg.value[i]
    #     * dut.filter_msg.value[len(dut.input_arr_msg.value) - i - 1]
    # )

    # assert that val and rdy bits have been set correctly
    # assert dut.input_arr_rdy.value == 1
    # assert dut.filter_rdy.value == 1
    # assert dut.output_arr_val.value == 1


@cocotb.test()
async def multiply_tests(dut):
    # for _ in range(1000):
    #     # input_arr = np.random.randint(low=0, high=np.iinfo(np.int32).max, size=8, dtype=np.int32).tolist();
    #     # filter = np.random.randint(low=0, high=np.iinfo(np.int32).max, size=8, dtype=np.int32).tolist();
    #     input_arr = np.random.randint(
    #         low=0, high=np.iinfo(np.int16).max, size=8, dtype=np.int16
    #     ).tolist()
    #     filter = np.random.randint(
    #         low=0, high=np.iinfo(np.int16).max, size=8, dtype=np.int16
    #     ).tolist()
    #     await conv_test_gen(dut, input_arr, filter)
    await conv_test_gen(dut, [1, 0, 0, 0, 0, 0, 0, 2], [2, 0, 0, 0, 0, 0, 0, 1])


# async def val_rdy_test_gen(dut, in_val, filter_val, out_rdy, expected_in_rdy, expected_filter_rdy, expected_out_val):
#     dut.clk.value = 0

#     dut.input_arr_val.value = in_val
#     dut.filter_val.value = filter_val
#     dut.output_arr_rdy.value = out_rdy

#     await Timer(1, units="ns")
#     dut.clk.value = 1
#     await Timer(1, units="ns")

#     assert dut.input_arr_rdy.value == expected_in_rdy
#     assert dut.filter_rdy.value == expected_filter_rdy
#     assert dut.output_arr_val.value == expected_out_val

# @cocotb.test()
# async def val_rdy_test(dut):
#     await val_rdy_test_gen(dut, 1, 1, 1, 1, 1, 1)
#     await val_rdy_test_gen(dut, 0, 0, 0, 0, 0, 0)
