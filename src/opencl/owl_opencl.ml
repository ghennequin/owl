(*
 * OWL - an OCaml numerical library for scientific computing
 * Copyright (c) 2016-2017 Liang Wang <liang.wang@cl.cam.ac.uk>
 *)

open Ctypes

open Owl_opencl_utils

open Owl_opencl_generated



(** platform definition *)
module Platform = struct

  type info = {
    profile    : string;
    version    : string;
    name       : string;
    vendor     : string;
    extensions : string;
  }


  let get_platform_ids () =
    let _n = allocate uint32_t uint32_0 in
    clGetPlatformIDs uint32_0 cl_platform_id_ptr_null _n |> cl_check_err;
    let n = Unsigned.UInt32.to_int !@_n in
    let _platforms = allocate_n cl_platform_id n in
    clGetPlatformIDs !@_n _platforms magic_null |> cl_check_err;
    Array.init n (fun i -> !@(_platforms +@ i))


  let get_platform_info plf_id param_name =
    let param_name = Unsigned.UInt32.of_int param_name in
    let param_value_size_ret = allocate size_t size_0 in
    clGetPlatformInfo plf_id param_name size_0 null param_value_size_ret |> cl_check_err;

    let _param_value_size = Unsigned.Size_t.to_int !@param_value_size_ret in
    let param_value = allocate_n char ~count:_param_value_size |> Obj.magic in
    clGetPlatformInfo plf_id param_name !@param_value_size_ret param_value magic_null |> cl_check_err;
    (* null terminated string, so minus 1 *)
    Ctypes.string_from_ptr param_value (_param_value_size - 1)


  let get_info plf_id = {
    profile    = get_platform_info plf_id cl_PLATFORM_PROFILE;
    version    = get_platform_info plf_id cl_PLATFORM_VERSION;
    name       = get_platform_info plf_id cl_PLATFORM_NAME;
    vendor     = get_platform_info plf_id cl_PLATFORM_VENDOR;
    extensions = get_platform_info plf_id cl_PLATFORM_EXTENSIONS;
  }

end



(** device definition *)
module Device = struct

  type info = {
    name                  : string;
    profile               : string;
    vendor                : string;
    version               : string;
    driver_version        : string;
    opencl_c_version      : string;
    build_in_kernels      : string;
    typ                   : int;
    address_bits          : int;
    available             : bool;
    compiler_available    : bool;
    linker_available      : bool;
    global_mem_cache_size : int;
    global_mem_size       : int;
    max_clock_frequency   : int;
    max_compute_units     : int;
    max_parameter_size    : int;
    max_samplers          : int;
    reference_count       : int;
    extensions            : string;
    parent_device         : cl_device_id;
    platform              : cl_platform_id;
  }


  let get_device_ids plf_id =
    let dev_typ = Unsigned.UInt64.of_int cl_DEVICE_TYPE_ALL in
    let num_entries = Unsigned.UInt32.of_int 0 in
    let _num_devices = allocate uint32_t uint32_0 in
    clGetDeviceIDs plf_id dev_typ num_entries cl_device_id_ptr_null _num_devices |> cl_check_err;

    let num_entries = Unsigned.UInt32.to_int !@_num_devices in
    let _devices = allocate_n cl_device_id num_entries in
    clGetDeviceIDs plf_id dev_typ !@_num_devices _devices magic_null |> cl_check_err;
    Array.init num_entries (fun i -> !@(_devices +@ i))


  let get_device_info dev_id param_name =
    let param_name = Unsigned.UInt32.of_int param_name in
    let param_value_size_ret = allocate size_t size_0 in
    clGetDeviceInfo dev_id param_name size_0 null param_value_size_ret |> cl_check_err;

    let _param_value_size = Unsigned.Size_t.to_int !@param_value_size_ret in
    let param_value = allocate_n char ~count:_param_value_size |> Obj.magic in
    clGetDeviceInfo dev_id param_name !@param_value_size_ret param_value magic_null |> cl_check_err;
    param_value, _param_value_size


  let get_info dev_id = {
      name                  = ( let p, l = get_device_info dev_id cl_DEVICE_NAME in string_from_ptr p (l - 1) );
      profile               = ( let p, l = get_device_info dev_id cl_DEVICE_PROFILE in string_from_ptr p (l - 1) );
      vendor                = ( let p, l = get_device_info dev_id cl_DEVICE_VENDOR in string_from_ptr p (l - 1) );
      version               = ( let p, l = get_device_info dev_id cl_DEVICE_VERSION in string_from_ptr p (l - 1) );
      driver_version        = ( let p, l = get_device_info dev_id cl_DRIVER_VERSION in string_from_ptr p (l - 1) );
      opencl_c_version      = ( let p, l = get_device_info dev_id cl_DEVICE_OPENCL_C_VERSION in string_from_ptr p (l - 1) );
      build_in_kernels      = ( let p, l = get_device_info dev_id cl_DEVICE_BUILT_IN_KERNELS in string_from_ptr p (l - 1) );
      typ                   = ( let p, l = get_device_info dev_id cl_DEVICE_TYPE in !@(char_ptr_to_uint32_ptr p) |> Unsigned.UInt32.to_int );
      address_bits          = ( let p, l = get_device_info dev_id cl_DEVICE_ADDRESS_BITS in !@(char_ptr_to_uint32_ptr p) |> Unsigned.UInt32.to_int );
      available             = ( let p, l = get_device_info dev_id cl_DEVICE_AVAILABLE in !@(char_ptr_to_uint32_ptr p) |> Unsigned.UInt32.to_int |> ( = ) 1);
      compiler_available    = ( let p, l = get_device_info dev_id cl_DEVICE_COMPILER_AVAILABLE in !@(char_ptr_to_uint32_ptr p) |> Unsigned.UInt32.to_int |> ( = ) 1);
      linker_available      = ( let p, l = get_device_info dev_id cl_DEVICE_LINKER_AVAILABLE in !@(char_ptr_to_uint32_ptr p) |> Unsigned.UInt32.to_int |> ( = ) 1);
      global_mem_cache_size = ( let p, l = get_device_info dev_id cl_DEVICE_GLOBAL_MEM_CACHE_SIZE in !@(char_ptr_to_ulong_ptr p) |> Unsigned.ULong.to_int);
      global_mem_size       = ( let p, l = get_device_info dev_id cl_DEVICE_GLOBAL_MEM_SIZE in !@(char_ptr_to_ulong_ptr p) |> Unsigned.ULong.to_int);
      max_clock_frequency   = ( let p, l = get_device_info dev_id cl_DEVICE_MAX_CLOCK_FREQUENCY in !@(char_ptr_to_uint32_ptr p) |> Unsigned.UInt32.to_int );
      max_compute_units     = ( let p, l = get_device_info dev_id cl_DEVICE_MAX_COMPUTE_UNITS in !@(char_ptr_to_uint32_ptr p) |> Unsigned.UInt32.to_int );
      max_parameter_size    = ( let p, l = get_device_info dev_id cl_DEVICE_MAX_PARAMETER_SIZE in !@(char_ptr_to_uint32_ptr p) |> Unsigned.UInt32.to_int );
      max_samplers          = ( let p, l = get_device_info dev_id cl_DEVICE_MAX_SAMPLERS in !@(char_ptr_to_uint32_ptr p) |> Unsigned.UInt32.to_int );
      reference_count       = ( let p, l = get_device_info dev_id cl_DEVICE_REFERENCE_COUNT in !@(char_ptr_to_uint32_ptr p) |> Unsigned.UInt32.to_int );
      extensions            = ( let p, l = get_device_info dev_id cl_DEVICE_EXTENSIONS in string_from_ptr p (l - 1) );
      parent_device         = ( let p, l = get_device_info dev_id cl_DEVICE_PARENT_DEVICE in !@(char_ptr_to_cl_device_id_ptr p) );
      platform              = ( let p, l = get_device_info dev_id cl_DEVICE_PLATFORM in !@(char_ptr_to_cl_platform_id_ptr p) );
  }


end



(** context definition *)
module Context = struct

end



(** kernel definition *)
module Kernel = struct

end



(** program definition *)
module Program = struct

end



(** event definition *)
module Event = struct

end



(** command queue definition *)
module CommandQueue = struct

end



(** memory object definition *)
module MemoryObject = struct

end



(** buffer definition *)
module Buffer = struct

end



(** shared virtual memroy definition, required opencl 2.0 *)
module SVM = struct

end



(* ends here *)
