@def title = "OpenCLBoostCompute"

# Developing OpenCL programs with Boost Compute

\toc

Boost Compute is a C++ wrapper library for the OpenCL. It is a C++ interface to the computing platforms supporting OpenCL. More information at http://www.boost.org/doc/libs/1_65_1/libs/compute/doc/html/index.html#boost_compute.introduction

## Basic Steps of an OpenCL program
### Get the Device
```
boost::compute::device device =  compute::system::default_device();
```

### Create a context with this device
```
boost::compute::context context(device);
```
### Create a queue with this context and device
```
boost::compute::command_queue queue(context,device,compute::command_queue::enable_profiling);
```
The third argument is used to enable the profiling for this queue. This let the user to use the inbuilt OpenCL profiling commands to extract the profiling information for any event of this queue. If the profiling is not desired, just skip the 3rd argument and provide only first two.

### Create kernel source
```
const char vertex_kernel_source[] = "  __kernel void vertex_kernel_func( arg 1, arg 2, ...) { %%Kernel Body%% }";
```
The kernel source is a string with all the kernel functions inside. The kernel source can contain multiple OpenCL kernels. A kernel function is like a normal C function with "__kernel" keyword in front of the function definition. The kernel body uses OpenCL C language which is much like ANSI C. (OpenCL C specifications at https://www.khronos.org/registry/OpenCL/specs/opencl-2.0-openclc.pdf)

### Build kernel source to get program
```
boost::compute::program vertex_program = compute::program::build_with_source(vertex_kernel_source,context);
```
The OpenCL kernels are buiild during the runtime. Build the kernel source and get the built program.

### Get kernel out of the built program
```
boost::compute::kernel vertex_kernel(vertex_program, "vertex_kernel_func");
```
The first argument to the kernel constructor is the built program and the second argument is a string with the name of the kernel.

### Perform memory transfer to the device
```
boost::compute::copy_async(p_weight,p_weight+nb_vertices*nb_joints,p_weight_CL.begin(),queue);          // for asynchronous memory transfer (transfer happens independent of the computation on device)

boost::compute::copy(p_weight,p_weight+nb_vertices*nb_joints,p_weight_CL.begin(),queue);                // for synchronous memory transfer (the device doesn't start the next computation until the memory transfer is finished)
```
The input data to the kernel must be first transferred to the device's  memory from the host memory. The first argument of the copy function is the starting pointer to the source memory. The second argument is the end pointer to the source memory. The third argument is the starting pointer to the destination memory. The iterators can also be used.

### Link the kernel arguments to the device buffers
```
vertex_kernel.set_arg(0,p_weight_CL);
```
Once the data is on the device memory, it is need to be mapped to the arguments of the kernel. The first argument of the "set_arg" function is a number which represent the index of the argument in the kernel definition. For example, "0" represent the first argument ("arg 1") in the kernel function definition. The second argument of the "set_arg" function is the variable in the device's memory.

### Enqueue the kernel execution
```
boost::compute::event kernel_exec = queue.enqueue_1d_range_kernel(vertex_kernel,0,nb_vertices,0);
```
Now we have the kernel and the arguments in the device's memory and hence we can enqueue the kernel computation. The first argument of enqueue function is the kernel. The second, third and fourth argument is the global work offset, global work size and local work size respectively.

### Transfer output of the kernel from device to host memory
```
boost::compute::copy_async(output_row_CL.begin(),output_row_CL.end(),output_row,queue)
```

## Debugging and Profiling OpenCL programs
### Debugging an OpenCL kernel
The OpenCL kernel is build during the run-time. If the kernel build fails then you can debug it by defining a macro BOOST_COMPUTE_DEBUG_KERNEL_COMPILATION at the start of your program. This will flush the build logs into the stdout.

### Double support on OpenCL version <= 1.1
The OpenCL version <= 1.1  does not support the "double" type by default. One needs to enable the cl_khr_fp64 extension in the OpenCL kernel to use the double data type. It can be enabled by adding following line at the start of the kernel source file:
```
#pragma OPENCL EXTENSION cl_khr_fp64 : enable
```
### Profiling OpenCL programs
Profiling in OpenCL can be done in two ways.

- OpenCL profilers provided by different vendors.
- In-built profiling commands in OpenCL.
#### OpenCL profilers by vendors
**Nvidia**

Most of the Nvidia devices has the OpenCL capability, but there is no OpenCL profiling tool from Nvidia.

**AMD**

CodeXL is the best tool for OpenCL debugging and profiling but it works only on the AMD devices (CPUs and GPUs). CodeXL is available freely.

**Intel**

Intel VTune Amplifier is the profiling tool from Intel, but like AMD, it works only on the Intel devices (CPUs and GPUs). Intel VTune Amplifier is not free but a trial version for 30 days is there.

#### In-built profiling commands in OpenCL
Since there is no profiling tool that can be used independent of the computing platform, one can use in-built profiling commands provided in OpenCL specifications. This is the best option if one wants to do profiling on Nvidia devices, or the program uses multiple devices from different vendors.

To enable the in-built OpenCL profiling, one should create the profiling enabled command queue (see the command queue creation in the section "Basic steps of an OpenCL program"). The profiling in OpenCL is done by using the event objects. An event in OpenCL is an object that communicates the status of OpenCL commands (queuing a kernel execution, memory operations). The event is object returned during the call to the OpenCL queuing or memory transfer commands.
```
boost::compute::future<void> memcpy_out = compute::copy_async(output_row_CL.begin(),output_row_CL.end(),output_row,queue);                    // Memory transfer event
 
boost::compute::event kernel_exec = queue.enqueue_1d_range_kernel(vertex_kernel,0,nb_vertices,0);                                           // Kernel execution event
```
Here, we get the event objects "memcpy_out" and "kenrel_exec" for memory transfer and kernel execution respectively. The event object has all the profiling information about the event and can be extracted from it.

There are four types of profiling information for the OpenCL event.

- CL_PROFILING_COMMAND_QUEUED (cl_ulong) - A 64-bit value that describes the current device time counter in nanoseconds when the command identified by event is enqueued in a command-queue by the host.
- CL_PROFILING_COMMAND_SUBMIT (cl_ulong) - A 64-bit value that describes the current device time counter in nanoseconds when the command identified by event that has been enqueued is submitted by the host to the device associated with the command queue.
- CL_PROFILING_COMMAND_START (cl_ulong) - A 64-bit value that describes the current device time counter in nanoseconds when the command identified by event starts execution on the device.
- CL_PROFILING_COMMAND_END (cl_ulong) - A 64-bit value that describes the current device time counter in nanoseconds when the command identified by event has finished execution on the device.
    The desired profiling information is collected from the object using the function "get_profiling_info" as shown:
```
event_object.get_profiling_info<cl_ulong>(boost::compute::event::profiling_command_queued);
event_object.get_profiling_info<cl_ulong>(boost::compute::event::profiling_command_submit);
event_object.get_profiling_info<cl_ulong>(boost::compute::event::profiling_command_start);
event_object.get_profiling_info<cl_ulong>(boost::compute::event::profiling_command_end);
```
This information can be dumped in a log file and can be read using a python or matlab script for analysis.

