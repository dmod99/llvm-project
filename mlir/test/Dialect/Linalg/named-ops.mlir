// RUN: mlir-opt -split-input-file -verify-diagnostics %s | FileCheck %s

// CHECK-LABEL: func @depthwise_conv_1d_nwc_wcm
func.func @depthwise_conv_1d_nwc_wcm(%input: tensor<1x12x8xf32>, %filter: tensor<3x8x8xf32>) -> tensor<1x10x8x8xf32> {
  %zero = arith.constant 0.000000e+00 : f32
  %init = tensor.empty() : tensor<1x10x8x8xf32>
  %fill = linalg.fill ins(%zero : f32) outs(%init : tensor<1x10x8x8xf32>) -> tensor<1x10x8x8xf32>
  // CHECK: depthwise_conv_1d_nwc_wcm
  %0 = linalg.depthwise_conv_1d_nwc_wcm {dilations = dense<1> : tensor<1xi64>, strides = dense<1> : tensor<1xi64>}
    ins(%input, %filter : tensor<1x12x8xf32>, tensor<3x8x8xf32>)
    outs(%fill : tensor<1x10x8x8xf32>) -> tensor<1x10x8x8xf32>
  return %0 : tensor<1x10x8x8xf32>
}

// -----

// CHECK-LABEL: func @depthwise_conv_1d_nwc_wc
func.func @depthwise_conv_1d_nwc_wc(%input: tensor<1x12x8xf32>, %filter: tensor<3x8xf32>) -> tensor<1x10x8xf32> {
  %zero = arith.constant 0.000000e+00 : f32
  %init = tensor.empty() : tensor<1x10x8xf32>
  %fill = linalg.fill ins(%zero : f32) outs(%init : tensor<1x10x8xf32>) -> tensor<1x10x8xf32>
  // CHECK: depthwise_conv_1d_nwc_wc
  %0 = linalg.depthwise_conv_1d_nwc_wc {dilations = dense<1> : tensor<1xi64>, strides = dense<1> : tensor<1xi64>}
    ins(%input, %filter : tensor<1x12x8xf32>, tensor<3x8xf32>)
    outs(%fill : tensor<1x10x8xf32>) -> tensor<1x10x8xf32>
  return %0 : tensor<1x10x8xf32>
}

// -----

// CHECK-LABEL: func @depthwise_conv_2d_nhwc_hwcm_tensor
func.func @depthwise_conv_2d_nhwc_hwcm_tensor(%input: tensor<2x4x5x2xf32>, %filter: tensor<2x2x2x3xf32>) -> tensor<2x3x4x2x3xf32> {
  %zero = arith.constant 0.000000e+00 : f32
  %init = tensor.empty() : tensor<2x3x4x2x3xf32>
  %fill = linalg.fill ins(%zero : f32) outs(%init : tensor<2x3x4x2x3xf32>) -> tensor<2x3x4x2x3xf32>
  // CHECK:      %{{.+}} = linalg.depthwise_conv_2d_nhwc_hwcm
  // CHECK-SAME:   {dilations = dense<1> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>}
  // CHECK-SAME:   ins(%{{.+}}, %{{.+}} : tensor<2x4x5x2xf32>, tensor<2x2x2x3xf32>)
  // CHECK-SAME:   outs(%{{.+}} : tensor<2x3x4x2x3xf32>)
  %0 = linalg.depthwise_conv_2d_nhwc_hwcm
     { dilations = dense<1> : tensor<2xi64>, strides = dense<1> : tensor<2xi64> }
     ins(%input, %filter : tensor<2x4x5x2xf32>, tensor<2x2x2x3xf32>)
    outs(%fill : tensor<2x3x4x2x3xf32>) -> tensor<2x3x4x2x3xf32>
  return %0 : tensor<2x3x4x2x3xf32>
}

// CHECK-LABEL: func @depthwise_conv_2d_nhwc_hwcm_memref
func.func @depthwise_conv_2d_nhwc_hwcm_memref(%input: memref<2x4x5x2xf32>, %filter: memref<2x2x2x3xf32>, %output: memref<2x3x4x2x3xf32>) {
  // CHECK:      linalg.depthwise_conv_2d_nhwc_hwcm
  // CHECK-SAME:   {dilations = dense<1> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>}
  // CHECK-SAME:   ins(%{{.+}}, %{{.+}} : memref<2x4x5x2xf32>, memref<2x2x2x3xf32>)
  // CHECK-SAME:   outs(%{{.+}} : memref<2x3x4x2x3xf32>)
  linalg.depthwise_conv_2d_nhwc_hwcm
     { dilations = dense<1> : tensor<2xi64>, strides = dense<1> : tensor<2xi64> }
     ins(%input, %filter : memref<2x4x5x2xf32>, memref<2x2x2x3xf32>)
    outs(%output : memref<2x3x4x2x3xf32>)
  return
}

// CHECK-LABEL: func @depthwise_conv_1d_nw_tensor
func.func @depthwise_conv_1d_nw_tensor(%input: tensor<1x113x96xf32>, %filter: tensor<3x96xf32>) -> tensor<1x56x96xf32> {
  %init = tensor.empty() : tensor<1x56x96xf32>
  // CHECK:      %{{.+}} = linalg.depthwise_conv_1d_nw
  // CHECK-SAME:   {dilations = dense<1> : vector<1xi64>, strides = dense<2> : vector<1xi64>}
  // CHECK-SAME:   ins(%{{.+}}, %{{.+}} : tensor<1x113x96xf32>, tensor<3x96xf32>)
  // CHECK-SAME:   outs(%{{.+}} : tensor<1x56x96xf32>) -> tensor<1x56x96xf32>
  %0 = linalg.depthwise_conv_1d_nwc_wc {dilations = dense<1> : vector<1xi64>, strides = dense<2> : vector<1xi64>}
         ins(%input, %filter: tensor<1x113x96xf32>, tensor<3x96xf32>)
         outs(%init: tensor<1x56x96xf32>) -> tensor<1x56x96xf32>
  return %0: tensor<1x56x96xf32>
}

// CHECK-LABEL: func @depthwise_conv_2d_nhwc_hwc_tensor
func.func @depthwise_conv_2d_nhwc_hwc_tensor(%input: tensor<1x113x113x96xf32>, %filter: tensor<3x3x96xf32>) -> tensor<1x56x56x96xf32> {
  %init = tensor.empty() : tensor<1x56x56x96xf32>
  // CHECK:      %{{.+}} = linalg.depthwise_conv_2d_nhwc_hwc
  // CHECK-SAME:   {dilations = dense<1> : vector<2xi64>, strides = dense<2> : vector<2xi64>}
  // CHECK-SAME:   ins(%{{.+}}, %{{.+}} : tensor<1x113x113x96xf32>, tensor<3x3x96xf32>)
  // CHECK-SAME:   outs(%{{.+}} : tensor<1x56x56x96xf32>) -> tensor<1x56x56x96xf32>
  %0 = linalg.depthwise_conv_2d_nhwc_hwc {dilations = dense<1> : vector<2xi64>, strides = dense<2> : vector<2xi64>}
         ins(%input, %filter: tensor<1x113x113x96xf32>, tensor<3x3x96xf32>)
         outs(%init: tensor<1x56x56x96xf32>) -> tensor<1x56x56x96xf32>
  return %0: tensor<1x56x56x96xf32>
}

// CHECK-LABEL: func @depthwise_conv_2d_nhwc_hwc_memref
func.func @depthwise_conv_2d_nhwc_hwc_memref(%input: memref<1x113x113x96xf32>, %filter: memref<3x3x96xf32>, %output: memref<1x56x56x96xf32>) {
  // CHECK:      linalg.depthwise_conv_2d_nhwc_hwc
  // CHECK-SAME:   {dilations = dense<1> : vector<2xi64>, strides = dense<2> : vector<2xi64>}
  // CHECK-SAME:   ins(%{{.+}}, %{{.+}} : memref<1x113x113x96xf32>, memref<3x3x96xf32>)
  // CHECK-SAME:   outs(%{{.+}} : memref<1x56x56x96xf32>)
  linalg.depthwise_conv_2d_nhwc_hwc {dilations = dense<1> : vector<2xi64>, strides = dense<2> : vector<2xi64>}
    ins(%input, %filter: memref<1x113x113x96xf32>, memref<3x3x96xf32>)
    outs(%output: memref<1x56x56x96xf32>)
  return
}

// CHECK-LABEL: func @depthwise_conv_2d_nchw_chw_tensor
func.func @depthwise_conv_2d_nchw_chw_tensor(%input: tensor<1x96x113x113xf32>, %filter: tensor<96x3x3xf32>) -> tensor<1x96x56x56xf32> {
  %init = tensor.empty() : tensor<1x96x56x56xf32>
  // CHECK:      %{{.+}} = linalg.depthwise_conv_2d_nchw_chw
  // CHECK-SAME:   {dilations = dense<1> : vector<2xi64>, strides = dense<2> : vector<2xi64>}
  // CHECK-SAME:   ins(%{{.+}}, %{{.+}} : tensor<1x96x113x113xf32>, tensor<96x3x3xf32>)
  // CHECK-SAME:   outs(%{{.+}} : tensor<1x96x56x56xf32>) -> tensor<1x96x56x56xf32>
  %0 = linalg.depthwise_conv_2d_nchw_chw {dilations = dense<1> : vector<2xi64>, strides = dense<2> : vector<2xi64>}
         ins(%input, %filter: tensor<1x96x113x113xf32>, tensor<96x3x3xf32>)
         outs(%init: tensor<1x96x56x56xf32>) -> tensor<1x96x56x56xf32>
  return %0: tensor<1x96x56x56xf32>
}

// CHECK-LABEL: func @depthwise_conv_2d_nchw_chw_memref
func.func @depthwise_conv_2d_nchw_chw_memref(%input: memref<1x96x113x113xf32>, %filter: memref<96x3x3xf32>, %output: memref<1x96x56x56xf32>) {
  // CHECK:      linalg.depthwise_conv_2d_nchw_chw
  // CHECK-SAME:   {dilations = dense<1> : vector<2xi64>, strides = dense<2> : vector<2xi64>}
  // CHECK-SAME:   ins(%{{.+}}, %{{.+}} : memref<1x96x113x113xf32>, memref<96x3x3xf32>)
  // CHECK-SAME:   outs(%{{.+}} : memref<1x96x56x56xf32>)
  linalg.depthwise_conv_2d_nchw_chw {dilations = dense<1> : vector<2xi64>, strides = dense<2> : vector<2xi64>}
    ins(%input, %filter: memref<1x96x113x113xf32>, memref<96x3x3xf32>)
    outs(%output: memref<1x96x56x56xf32>)
  return
}

func.func @depthwise_conv_2d_nhwc_hwcm_tensor_dilated(%input: tensor<2x8x9x2xf32>, %filter: tensor<2x2x2x3xf32>) -> tensor<2x6x7x2x3xf32> {
  %zero = arith.constant 0.000000e+00 : f32
  %init = tensor.empty() : tensor<2x6x7x2x3xf32>
  %fill = linalg.fill ins(%zero : f32) outs(%init : tensor<2x6x7x2x3xf32>) -> tensor<2x6x7x2x3xf32>
  // CHECK:      %{{.+}} = linalg.depthwise_conv_2d_nhwc_hwcm
  // CHECK-SAME:   {dilations = dense<2> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>}
  // CHECK-SAME:   ins(%{{.+}}, %{{.+}} : tensor<2x8x9x2xf32>, tensor<2x2x2x3xf32>)
  // CHECK-SAME:   outs(%{{.+}} : tensor<2x6x7x2x3xf32>)
  %0 = linalg.depthwise_conv_2d_nhwc_hwcm
     { dilations = dense<2> : tensor<2xi64>, strides = dense<1> : tensor<2xi64> }
     ins(%input, %filter : tensor<2x8x9x2xf32>, tensor<2x2x2x3xf32>)
    outs(%fill : tensor<2x6x7x2x3xf32>) -> tensor<2x6x7x2x3xf32>
  return %0 : tensor<2x6x7x2x3xf32>
}

// CHECK-LABEL: func @depthwise_conv_2d_nhwc_hwcm_memref_dilated
func.func @depthwise_conv_2d_nhwc_hwcm_memref_dilated(%input: memref<2x8x9x2xf32>, %filter: memref<2x2x2x3xf32>, %output: memref<2x6x7x2x3xf32>) {
  // CHECK:      linalg.depthwise_conv_2d_nhwc_hwcm
  // CHECK-SAME:   {dilations = dense<2> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>}
  // CHECK-SAME:   ins(%{{.+}}, %{{.+}} : memref<2x8x9x2xf32>, memref<2x2x2x3xf32>)
  // CHECK-SAME:   outs(%{{.+}} : memref<2x6x7x2x3xf32>)
  linalg.depthwise_conv_2d_nhwc_hwcm
     { dilations = dense<2> : tensor<2xi64>, strides = dense<1> : tensor<2xi64> }
     ins(%input, %filter : memref<2x8x9x2xf32>, memref<2x2x2x3xf32>)
    outs(%output : memref<2x6x7x2x3xf32>)
  return
}

// -----

// CHECK-LABEL: func @depthwise_conv_2d_input_nhwc_filter_default_attributes
func.func @depthwise_conv_2d_input_nhwc_filter_default_attributes(%input: memref<1x113x113x96xf32>, %filter: memref<3x3x96xf32>, %output: memref<1x56x56x96xf32>) {
  // CHECK:      linalg.depthwise_conv_2d_nhwc_hwc
  // CHECK-NOT:  strides =
  // CHECK-NOT:  dilations =
  linalg.depthwise_conv_2d_nhwc_hwc
    ins(%input, %filter: memref<1x113x113x96xf32>, memref<3x3x96xf32>)
    outs(%output: memref<1x56x56x96xf32>)
  return
}

// -----

func.func @depthwise_conv_2d_input_nhwc_filter_wrong_stride_element_type_properties(%input: memref<1x113x113x96xf32>, %filter: memref<3x3x96xf32>, %output: memref<1x56x56x96xf32>) {
  // expected-error @+1 {{invalid properties {dilations = dense<1> : vector<2xi64>, operand_segment_sizes = array<i32: 2, 1>, strides = dense<2.000000e+00> : vector<2xf32>} for op linalg.depthwise_conv_2d_nhwc_hwc: Invalid attribute `strides` in property conversion: dense<2.000000e+00> : vector<2xf32>}}
  linalg.depthwise_conv_2d_nhwc_hwc <{dilations = dense<1> : vector<2xi64>, strides = dense<2.0> : vector<2xf32>}>
    ins(%input, %filter: memref<1x113x113x96xf32>, memref<3x3x96xf32>)
    outs(%output: memref<1x56x56x96xf32>)
  return
}

// -----

func.func @depthwise_conv_2d_input_nhwc_filter_wrong_stride_element_type(%input: memref<1x113x113x96xf32>, %filter: memref<3x3x96xf32>, %output: memref<1x56x56x96xf32>) {
  // expected-error @+1 {{op attribute 'strides' failed to satisfy constraint: 64-bit signless int elements attribute of shape [2]}}
  linalg.depthwise_conv_2d_nhwc_hwc {dilations = dense<1> : vector<2xi64>, strides = dense<2.0> : vector<2xf32>}
    ins(%input, %filter: memref<1x113x113x96xf32>, memref<3x3x96xf32>)
    outs(%output: memref<1x56x56x96xf32>)
  return
}

// -----

func.func @depthwise_conv_2d_input_nhwc_filter_wrong_stride_size(%input: memref<1x113x113x96xf32>, %filter: memref<3x3x96xf32>, %output: memref<1x56x56x96xf32>) {
  // expected-error @+1 {{op attribute 'strides' failed to satisfy constraint: 64-bit signless int elements attribute of shape [2]}}
  linalg.depthwise_conv_2d_nhwc_hwc {dilations = dense<1> : vector<2xi64>, strides = dense<2> : vector<3xi64> }
    ins(%input, %filter: memref<1x113x113x96xf32>, memref<3x3x96xf32>)
    outs(%output: memref<1x56x56x96xf32>)
  return
}

// -----

// CHECK-LABEL: func @depthwise_conv_3d_ndhwc_dhwcm
func.func @depthwise_conv_3d_ndhwc_dhwcm(%input: tensor<2x6x13x12x6xf32>, %filter: tensor<2x1x3x6x6xf32>) -> tensor<2x3x13x4x6x6xf32> {
  %zero = arith.constant 0.000000e+00 : f32
  %init = tensor.empty() : tensor<2x3x13x4x6x6xf32>
  %fill = linalg.fill ins(%zero : f32) outs(%init : tensor<2x3x13x4x6x6xf32>) -> tensor<2x3x13x4x6x6xf32>
  // CHECK: depthwise_conv_3d_ndhwc_dhwcm
  %0 = linalg.depthwise_conv_3d_ndhwc_dhwcm {dilations = dense<1> : tensor<3xi64>, strides = dense<[2, 1, 3]> : tensor<3xi64>}
    ins(%input, %filter : tensor<2x6x13x12x6xf32>, tensor<2x1x3x6x6xf32>)
    outs(%fill : tensor<2x3x13x4x6x6xf32>) -> tensor<2x3x13x4x6x6xf32>
  return %0 : tensor<2x3x13x4x6x6xf32>
}

// -----

// CHECK-LABEL: func @depthwise_conv_3d_ndhwc_dhwc
func.func @depthwise_conv_3d_ndhwc_dhwc(%input: tensor<2x6x13x12x6xf32>, %filter: tensor<2x1x3x6xf32>) -> tensor<2x3x13x4x6xf32> {
  %zero = arith.constant 0.000000e+00 : f32
  %init = tensor.empty() : tensor<2x3x13x4x6xf32>
  %fill = linalg.fill ins(%zero : f32) outs(%init : tensor<2x3x13x4x6xf32>) -> tensor<2x3x13x4x6xf32>
  // CHECK: depthwise_conv_3d_ndhwc_dhwc
  %0 = linalg.depthwise_conv_3d_ndhwc_dhwc {dilations = dense<1> : tensor<3xi64>, strides = dense<[2, 1, 3]> : tensor<3xi64>}
    ins(%input, %filter : tensor<2x6x13x12x6xf32>, tensor<2x1x3x6xf32>)
    outs(%fill : tensor<2x3x13x4x6xf32>) -> tensor<2x3x13x4x6xf32>
  return %0 : tensor<2x3x13x4x6xf32>
}

// -----

// CHECK-LABEL: func @conv_1d_nwc_wcf
func.func @conv_1d_nwc_wcf(%input: tensor<?x?x?xf32>, %filter: tensor<?x?x?xf32>, %init: tensor<?x?x?xf32>) -> tensor<?x?x?xf32> {
  // CHECK:      %{{.+}} = linalg.conv_1d_nwc_wcf
  // CHECK-SAME:   dilations = dense<1> : tensor<1xi64>
  // CHECK-SAME:   strides = dense<1> : tensor<1xi64>
  // CHECK-SAME:   ins(%{{.+}}, %{{.+}} : tensor<?x?x?xf32>, tensor<?x?x?xf32>)
  // CHECK-SAME:   outs(%{{.+}} : tensor<?x?x?xf32>) -> tensor<?x?x?xf32>
  %0 = linalg.conv_1d_nwc_wcf {dilations = dense<1> : tensor<1xi64>,
                                            strides = dense<1> : tensor<1xi64>}
     ins (%input, %filter: tensor<?x?x?xf32>, tensor<?x?x?xf32>)
    outs (%init: tensor<?x?x?xf32>) -> tensor<?x?x?xf32>
  return %0 : tensor<?x?x?xf32>
}

// -----

// CHECK-LABEL: func @conv_1d_nwc_wcf
func.func @conv_1d_nwc_wcf(%input: memref<?x?x?xf32>, %filter: memref<?x?x?xf32>, %output: memref<?x?x?xf32>) {
  // CHECK:      linalg.conv_1d_nwc_wcf
  // CHECK-SAME:   dilations = dense<1> : tensor<1xi64>
  // CHECK-SAME:   strides = dense<1> : tensor<1xi64>
  // CHECK-SAME:   ins(%{{.+}}, %{{.+}} : memref<?x?x?xf32>, memref<?x?x?xf32>)
  // CHECK-SAME:   outs(%{{.+}} : memref<?x?x?xf32>)
  linalg.conv_1d_nwc_wcf {dilations = dense<1> : tensor<1xi64>,
                                       strides = dense<1> : tensor<1xi64>}
     ins (%input, %filter: memref<?x?x?xf32>, memref<?x?x?xf32>)
    outs (%output: memref<?x?x?xf32>)
  return
}

// -----

// CHECK-LABEL: func @conv_1d_ncw_fcw
func.func @conv_1d_ncw_fcw(%input: tensor<?x?x?xf32>, %filter: tensor<?x?x?xf32>, %init: tensor<?x?x?xf32>) -> tensor<?x?x?xf32> {
  // CHECK:      %{{.+}} = linalg.conv_1d_ncw_fcw
  // CHECK-SAME:   dilations = dense<1> : tensor<1xi64>
  // CHECK-SAME:   strides = dense<1> : tensor<1xi64>
  // CHECK-SAME:   ins(%{{.+}}, %{{.+}} : tensor<?x?x?xf32>, tensor<?x?x?xf32>)
  // CHECK-SAME:   outs(%{{.+}} : tensor<?x?x?xf32>) -> tensor<?x?x?xf32>
  %0 = linalg.conv_1d_ncw_fcw {dilations = dense<1> : tensor<1xi64>,
                                            strides = dense<1> : tensor<1xi64>}
     ins (%input, %filter: tensor<?x?x?xf32>, tensor<?x?x?xf32>)
    outs (%init: tensor<?x?x?xf32>) -> tensor<?x?x?xf32>
  return %0 : tensor<?x?x?xf32>
}

// -----

// CHECK-LABEL: func @conv_1d_ncw_fcw
func.func @conv_1d_ncw_fcw(%input: memref<?x?x?xf32>, %filter: memref<?x?x?xf32>, %output: memref<?x?x?xf32>) {
  // CHECK:      linalg.conv_1d_ncw_fcw
  // CHECK-SAME:   dilations = dense<1> : tensor<1xi64>
  // CHECK-SAME:   strides = dense<1> : tensor<1xi64>
  // CHECK-SAME:   ins(%{{.+}}, %{{.+}} : memref<?x?x?xf32>, memref<?x?x?xf32>)
  // CHECK-SAME:   outs(%{{.+}} : memref<?x?x?xf32>)
  linalg.conv_1d_ncw_fcw {dilations = dense<1> : tensor<1xi64>,
                                       strides = dense<1> : tensor<1xi64>}
     ins (%input, %filter: memref<?x?x?xf32>, memref<?x?x?xf32>)
    outs (%output: memref<?x?x?xf32>)
  return
}

// -----

// CHECK-LABEL: func @conv_2d_nhwc_hwcf
func.func @conv_2d_nhwc_hwcf(%input: tensor<?x?x?x?xf32>, %filter: tensor<?x?x?x?xf32>, %init: tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32> {
  // CHECK:      %{{.+}} = linalg.conv_2d_nhwc_hwcf
  // CHECK-SAME:   dilations = dense<1> : tensor<2xi64>
  // CHECK-SAME:   strides = dense<1> : tensor<2xi64>
  // CHECK-SAME:   ins(%{{.+}}, %{{.+}} : tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>)
  // CHECK-SAME:   outs(%{{.+}} : tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
  %0 = linalg.conv_2d_nhwc_hwcf {dilations = dense<1> : tensor<2xi64>,
                                              strides = dense<1> : tensor<2xi64>}
     ins (%input, %filter: tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>)
    outs (%init: tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
  return %0 : tensor<?x?x?x?xf32>
}

// -----

// CHECK-LABEL: func @conv_2d_ngchw_fgchw
func.func @conv_2d_ngchw_fgchw(%input: tensor<?x?x?x?x?xf32>, %filter: tensor<?x?x?x?x?xf32>, %init: tensor<?x?x?x?x?xf32>) -> tensor<?x?x?x?x?xf32> {
  // CHECK:      %{{.+}} = linalg.conv_2d_ngchw_fgchw
  // CHECK-SAME:   dilations = dense<1> : tensor<2xi64>
  // CHECK-SAME:   strides = dense<1> : tensor<2xi64>
  // CHECK-SAME:   ins(%{{.+}}, %{{.+}} : tensor<?x?x?x?x?xf32>, tensor<?x?x?x?x?xf32>)
  // CHECK-SAME:   outs(%{{.+}} : tensor<?x?x?x?x?xf32>) -> tensor<?x?x?x?x?xf32>
  %0 = linalg.conv_2d_ngchw_fgchw {dilations = dense<1> : tensor<2xi64>,
                                              strides = dense<1> : tensor<2xi64>}
     ins (%input, %filter: tensor<?x?x?x?x?xf32>, tensor<?x?x?x?x?xf32>)
    outs (%init: tensor<?x?x?x?x?xf32>) -> tensor<?x?x?x?x?xf32>
  return %0 : tensor<?x?x?x?x?xf32>
}

// -----

// CHECK-LABEL: func @conv_2d_nhwc_fhwc
func.func @conv_2d_nhwc_fhwc(%input: tensor<?x?x?x?xf32>, %filter: tensor<?x?x?x?xf32>, %init: tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32> {
  // CHECK:      %{{.+}} = linalg.conv_2d_nhwc_fhwc
  // CHECK-SAME:   dilations = dense<1> : tensor<2xi64>
  // CHECK-SAME:   strides = dense<1> : tensor<2xi64>
  // CHECK-SAME:   ins(%{{.+}}, %{{.+}} : tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>)
  // CHECK-SAME:   outs(%{{.+}} : tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
  %0 = linalg.conv_2d_nhwc_fhwc {dilations = dense<1> : tensor<2xi64>,
                                 strides = dense<1> : tensor<2xi64>}
     ins (%input, %filter: tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>)
    outs (%init: tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
  return %0 : tensor<?x?x?x?xf32>
}

// -----

// CHECK-LABEL: func @conv_2d_nhwc_fhwc_static
func.func @conv_2d_nhwc_fhwc_static(%input: tensor<?x128x128x32xf32>, %filter: tensor<64x3x3x32xf32>, %init: tensor<?x126x126x64xf32>) -> tensor<?x126x126x64xf32> {
  // CHECK:      %{{.+}} = linalg.conv_2d_nhwc_fhwc
  // CHECK-SAME:   dilations = dense<1> : tensor<2xi64>
  // CHECK-SAME:   strides = dense<1> : tensor<2xi64>
  // CHECK-SAME:   ins(%{{.+}}, %{{.+}} : tensor<?x128x128x32xf32>, tensor<64x3x3x32xf32>)
  // CHECK-SAME:   outs(%{{.+}} : tensor<?x126x126x64xf32>) -> tensor<?x126x126x64xf32>
  %0 = linalg.conv_2d_nhwc_fhwc {dilations = dense<1> : tensor<2xi64>,
                                 strides = dense<1> : tensor<2xi64>}
     ins (%input, %filter: tensor<?x128x128x32xf32>, tensor<64x3x3x32xf32>)
    outs (%init: tensor<?x126x126x64xf32>) -> tensor<?x126x126x64xf32>
  return %0 : tensor<?x126x126x64xf32>
}

// -----

// CHECK-LABEL: func @conv_2d_nhwc_hwcf
func.func @conv_2d_nhwc_hwcf(%input: memref<?x?x?x?xf32>, %filter: memref<?x?x?x?xf32>, %output: memref<?x?x?x?xf32>) {
  // CHECK:      linalg.conv_2d_nhwc_hwcf
  // CHECK-SAME:   dilations = dense<1> : tensor<2xi64>
  // CHECK-SAME:   strides = dense<1> : tensor<2xi64>
  // CHECK-SAME:   ins(%{{.+}}, %{{.+}} : memref<?x?x?x?xf32>, memref<?x?x?x?xf32>)
  // CHECK-SAME:   outs(%{{.+}} : memref<?x?x?x?xf32>)
  linalg.conv_2d_nhwc_hwcf {dilations = dense<1> : tensor<2xi64>,
                                         strides = dense<1> : tensor<2xi64>}
     ins (%input, %filter: memref<?x?x?x?xf32>, memref<?x?x?x?xf32>)
    outs (%output: memref<?x?x?x?xf32>)
  return
}

// -----

// CHECK-LABEL: func @conv_2d_ngchw_fgchw
func.func @conv_2d_ngchw_fgchw(%input: memref<?x?x?x?x?xf32>, %filter: memref<?x?x?x?x?xf32>, %output: memref<?x?x?x?x?xf32>) {
  // CHECK:      linalg.conv_2d_ngchw_fgchw
  // CHECK-SAME:   dilations = dense<1> : tensor<2xi64>
  // CHECK-SAME:   strides = dense<1> : tensor<2xi64>
  // CHECK-SAME:   ins(%{{.+}}, %{{.+}} : memref<?x?x?x?x?xf32>, memref<?x?x?x?x?xf32>)
  // CHECK-SAME:   outs(%{{.+}} : memref<?x?x?x?x?xf32>)
  linalg.conv_2d_ngchw_fgchw {dilations = dense<1> : tensor<2xi64>,
                                         strides = dense<1> : tensor<2xi64>}
     ins (%input, %filter: memref<?x?x?x?x?xf32>, memref<?x?x?x?x?xf32>)
    outs (%output: memref<?x?x?x?x?xf32>)
  return
}

// -----

// CHECK-LABEL: func @conv_3d_ndhwc_dhwcf
func.func @conv_3d_ndhwc_dhwcf(%input: tensor<?x?x?x?x?xf32>, %filter: tensor<?x?x?x?x?xf32>, %init: tensor<?x?x?x?x?xf32>) -> tensor<?x?x?x?x?xf32> {
  // CHECK:      %{{.+}} = linalg.conv_3d_ndhwc_dhwcf
  // CHECK-SAME:   dilations = dense<1> : tensor<3xi64>
  // CHECK-SAME:   strides = dense<1> : tensor<3xi64>
  // CHECK-SAME:   ins(%{{.+}}, %{{.+}} : tensor<?x?x?x?x?xf32>, tensor<?x?x?x?x?xf32>)
  // CHECK-SAME:   outs(%{{.+}} : tensor<?x?x?x?x?xf32>) -> tensor<?x?x?x?x?xf32>
  %0 = linalg.conv_3d_ndhwc_dhwcf {dilations = dense<1> : tensor<3xi64>,
                                                strides = dense<1> : tensor<3xi64>}
     ins (%input, %filter: tensor<?x?x?x?x?xf32>, tensor<?x?x?x?x?xf32>)
    outs (%init: tensor<?x?x?x?x?xf32>) -> tensor<?x?x?x?x?xf32>
  return %0 : tensor<?x?x?x?x?xf32>
}

// -----

// CHECK-LABEL: func @conv_3d_ndhwc_dhwcf
func.func @conv_3d_ndhwc_dhwcf(%input: memref<?x?x?x?x?xf32>, %filter: memref<?x?x?x?x?xf32>, %output: memref<?x?x?x?x?xf32>) {
  // CHECK:      linalg.conv_3d_ndhwc_dhwcf
  // CHECK-SAME:   dilations = dense<1> : tensor<3xi64>
  // CHECK-SAME:   strides = dense<1> : tensor<3xi64>
  // CHECK-SAME:   ins(%{{.+}}, %{{.+}} : memref<?x?x?x?x?xf32>, memref<?x?x?x?x?xf32>)
  // CHECK-SAME:   outs(%{{.+}} : memref<?x?x?x?x?xf32>)
  linalg.conv_3d_ndhwc_dhwcf {dilations = dense<1> : tensor<3xi64>,
                                           strides = dense<1> : tensor<3xi64>}
     ins (%input, %filter: memref<?x?x?x?x?xf32>, memref<?x?x?x?x?xf32>)
    outs (%output: memref<?x?x?x?x?xf32>)
  return
}

// -----

// CHECK-LABEL: func @pooling_nhwc_sum_tensor
// CHECK:         %{{.+}} = linalg.pooling_nhwc_sum
// CHECK-SAME:      dilations = dense<1> : tensor<2xi64>
// CHECK-SAME:      strides = dense<1> : tensor<2xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : tensor<1x4x4x1xf32>, tensor<3x3xf32>)
// CHECK-SAME:      outs(%{{.+}} : tensor<1x2x2x1xf32>) -> tensor<1x2x2x1xf32>
func.func @pooling_nhwc_sum_tensor(%input: tensor<1x4x4x1xf32>) -> tensor<1x2x2x1xf32> {
  %fake = tensor.empty() : tensor<3x3xf32>
  %init = tensor.empty() : tensor<1x2x2x1xf32>
  %cst = arith.constant 0.000000e+00 : f32
  %fill = linalg.fill ins(%cst : f32) outs(%init : tensor<1x2x2x1xf32>) -> tensor<1x2x2x1xf32>
  %res = linalg.pooling_nhwc_sum {dilations = dense<1> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>}
    ins(%input, %fake: tensor<1x4x4x1xf32>, tensor<3x3xf32>)
    outs(%fill: tensor<1x2x2x1xf32>) -> tensor<1x2x2x1xf32>
  return %res : tensor<1x2x2x1xf32>
}

// -----

// CHECK-LABEL: func @pooling_nwc_sum_tensor
// CHECK:         %{{.+}} = linalg.pooling_nwc_sum
// CHECK-SAME:      dilations = dense<1> : tensor<1xi64>
// CHECK-SAME:      strides = dense<1> : tensor<1xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : tensor<1x4x1xf32>, tensor<3xf32>)
// CHECK-SAME:      outs(%{{.+}} : tensor<1x2x1xf32>) -> tensor<1x2x1xf32>
func.func @pooling_nwc_sum_tensor(%input: tensor<1x4x1xf32>) -> tensor<1x2x1xf32> {
  %fake = tensor.empty() : tensor<3xf32>
  %init = tensor.empty() : tensor<1x2x1xf32>
  %cst = arith.constant 0.000000e+00 : f32
  %fill = linalg.fill ins(%cst : f32) outs(%init : tensor<1x2x1xf32>) -> tensor<1x2x1xf32>
  %res = linalg.pooling_nwc_sum {dilations = dense<1> : tensor<1xi64>, strides = dense<1> : tensor<1xi64>}
    ins(%input, %fake: tensor<1x4x1xf32>, tensor<3xf32>)
    outs(%fill: tensor<1x2x1xf32>) -> tensor<1x2x1xf32>
  return %res : tensor<1x2x1xf32>
}

// -----

// CHECK-LABEL: func @pooling_nhwc_sum
// CHECK:         linalg.pooling_nhwc_sum
// CHECK-SAME:      dilations = dense<1> : tensor<2xi64>
// CHECK-SAME:      strides = dense<1> : tensor<2xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : memref<1x4x4x1xf32>, memref<3x3xf32>)
// CHECK-SAME:      outs(%{{.+}} : memref<1x2x2x1xf32>)
func.func @pooling_nhwc_sum(%input: memref<1x4x4x1xf32>, %fake: memref<3x3xf32>, %output: memref<1x2x2x1xf32>) {
  linalg.pooling_nhwc_sum {dilations = dense<1> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>}
    ins(%input, %fake: memref<1x4x4x1xf32>, memref<3x3xf32>)
    outs(%output: memref<1x2x2x1xf32>)
  return
}

// -----

// CHECK-LABEL: func @pooling_nwc_sum
// CHECK:         linalg.pooling_nwc_sum
// CHECK-SAME:      dilations = dense<1> : tensor<1xi64>
// CHECK-SAME:      strides = dense<1> : tensor<1xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : memref<1x4x1xf32>, memref<3xf32>)
// CHECK-SAME:      outs(%{{.+}} : memref<1x2x1xf32>)
func.func @pooling_nwc_sum(%input: memref<1x4x1xf32>, %fake: memref<3xf32>, %output: memref<1x2x1xf32>) {
  linalg.pooling_nwc_sum {dilations = dense<1> : tensor<1xi64>, strides = dense<1> : tensor<1xi64>}
    ins(%input, %fake: memref<1x4x1xf32>, memref<3xf32>)
    outs(%output: memref<1x2x1xf32>)
  return
}

// -----

// CHECK-LABEL: func @pooling_nchw_sum_tensor
// CHECK:         %{{.+}} = linalg.pooling_nchw_sum
// CHECK-SAME:      dilations = dense<1> : tensor<2xi64>
// CHECK-SAME:      strides = dense<1> : tensor<2xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : tensor<1x1x4x4xf32>, tensor<3x3xf32>)
// CHECK-SAME:      outs(%{{.+}} : tensor<1x1x2x2xf32>) -> tensor<1x1x2x2xf32>
func.func @pooling_nchw_sum_tensor(%input: tensor<1x1x4x4xf32>) -> tensor<1x1x2x2xf32> {
  %fake = tensor.empty() : tensor<3x3xf32>
  %init = tensor.empty() : tensor<1x1x2x2xf32>
  %cst = arith.constant 0.000000e+00 : f32
  %fill = linalg.fill ins(%cst : f32) outs(%init : tensor<1x1x2x2xf32>) -> tensor<1x1x2x2xf32>
  %res = linalg.pooling_nchw_sum {dilations = dense<1> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>}
    ins(%input, %fake: tensor<1x1x4x4xf32>, tensor<3x3xf32>)
    outs(%fill: tensor<1x1x2x2xf32>) -> tensor<1x1x2x2xf32>
  return %res : tensor<1x1x2x2xf32>
}

// -----

// CHECK-LABEL: func @pooling_ncw_sum_tensor
// CHECK:         %{{.+}} = linalg.pooling_ncw_sum
// CHECK-SAME:      dilations = dense<1> : tensor<1xi64>
// CHECK-SAME:      strides = dense<1> : tensor<1xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : tensor<1x1x4xf32>, tensor<3xf32>)
// CHECK-SAME:      outs(%{{.+}} : tensor<1x1x2xf32>) -> tensor<1x1x2xf32>
func.func @pooling_ncw_sum_tensor(%input: tensor<1x1x4xf32>) -> tensor<1x1x2xf32> {
  %fake = tensor.empty() : tensor<3xf32>
  %init = tensor.empty() : tensor<1x1x2xf32>
  %cst = arith.constant 0.000000e+00 : f32
  %fill = linalg.fill ins(%cst : f32) outs(%init : tensor<1x1x2xf32>) -> tensor<1x1x2xf32>
  %res = linalg.pooling_ncw_sum {dilations = dense<1> : tensor<1xi64>, strides = dense<1> : tensor<1xi64>}
    ins(%input, %fake: tensor<1x1x4xf32>, tensor<3xf32>)
    outs(%fill: tensor<1x1x2xf32>) -> tensor<1x1x2xf32>
  return %res : tensor<1x1x2xf32>
}

// -----

// CHECK-LABEL: func @pooling_nchw_sum
// CHECK:         linalg.pooling_nchw_sum
// CHECK-SAME:      dilations = dense<1> : tensor<2xi64>
// CHECK-SAME:      strides = dense<1> : tensor<2xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : memref<1x1x4x4xf32>, memref<3x3xf32>)
// CHECK-SAME:      outs(%{{.+}} : memref<1x1x2x2xf32>)
func.func @pooling_nchw_sum(%input: memref<1x1x4x4xf32>, %fake: memref<3x3xf32>, %output: memref<1x1x2x2xf32>) {
  linalg.pooling_nchw_sum {dilations = dense<1> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>}
    ins(%input, %fake: memref<1x1x4x4xf32>, memref<3x3xf32>)
    outs(%output: memref<1x1x2x2xf32>)
  return
}

// -----

// CHECK-LABEL: func @pooling_ncw_sum
// CHECK:         linalg.pooling_ncw_sum
// CHECK-SAME:      dilations = dense<1> : tensor<1xi64>
// CHECK-SAME:      strides = dense<1> : tensor<1xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : memref<1x1x4xf32>, memref<3xf32>)
// CHECK-SAME:      outs(%{{.+}} : memref<1x1x2xf32>)
func.func @pooling_ncw_sum(%input: memref<1x1x4xf32>, %fake: memref<3xf32>, %output: memref<1x1x2xf32>) {
  linalg.pooling_ncw_sum {dilations = dense<1> : tensor<1xi64>, strides = dense<1> : tensor<1xi64>}
    ins(%input, %fake: memref<1x1x4xf32>, memref<3xf32>)
    outs(%output: memref<1x1x2xf32>)
  return
}

// -----

// CHECK-LABEL: func @pooling_nhwc_max_tensor
// CHECK:         %{{.+}} = linalg.pooling_nhwc_max
// CHECK-SAME:      dilations = dense<1> : tensor<2xi64>
// CHECK-SAME:      strides = dense<1> : tensor<2xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : tensor<1x4x4x1xf32>, tensor<3x3xf32>)
// CHECK-SAME:      outs(%{{.+}} : tensor<1x2x2x1xf32>) -> tensor<1x2x2x1xf32>
func.func @pooling_nhwc_max_tensor(%input: tensor<1x4x4x1xf32>) -> tensor<1x2x2x1xf32> {
  %fake = tensor.empty() : tensor<3x3xf32>
  %init = tensor.empty() : tensor<1x2x2x1xf32>
  %cst = arith.constant 0.000000e+00 : f32
  %fill = linalg.fill ins(%cst : f32) outs(%init : tensor<1x2x2x1xf32>) -> tensor<1x2x2x1xf32>
  %res = linalg.pooling_nhwc_max {dilations = dense<1> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>}
    ins(%input, %fake: tensor<1x4x4x1xf32>, tensor<3x3xf32>)
    outs(%fill: tensor<1x2x2x1xf32>) -> tensor<1x2x2x1xf32>
  return %res : tensor<1x2x2x1xf32>
}

// -----
// CHECK-LABEL: func @pooling_nwc_max_tensor
// CHECK:         %{{.+}} = linalg.pooling_nwc_max
// CHECK-SAME:      dilations = dense<1> : tensor<1xi64>
// CHECK-SAME:      strides = dense<1> : tensor<1xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : tensor<1x4x1xf32>, tensor<3xf32>)
// CHECK-SAME:      outs(%{{.+}} : tensor<1x2x1xf32>) -> tensor<1x2x1xf32>
func.func @pooling_nwc_max_tensor(%input: tensor<1x4x1xf32>) -> tensor<1x2x1xf32> {
  %fake = tensor.empty() : tensor<3xf32>
  %init = tensor.empty() : tensor<1x2x1xf32>
  %cst = arith.constant 0.000000e+00 : f32
  %fill = linalg.fill ins(%cst : f32) outs(%init : tensor<1x2x1xf32>) -> tensor<1x2x1xf32>
  %res = linalg.pooling_nwc_max {dilations = dense<1> : tensor<1xi64>, strides = dense<1> : tensor<1xi64>}
    ins(%input, %fake: tensor<1x4x1xf32>, tensor<3xf32>)
    outs(%fill: tensor<1x2x1xf32>) -> tensor<1x2x1xf32>
  return %res : tensor<1x2x1xf32>
}

// -----
// CHECK-LABEL: func @pooling_nchw_max_tensor
// CHECK:         %{{.+}} = linalg.pooling_nchw_max
// CHECK-SAME:      dilations = dense<1> : tensor<2xi64>
// CHECK-SAME:      strides = dense<1> : tensor<2xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : tensor<1x1x4x4xf32>, tensor<3x3xf32>)
// CHECK-SAME:      outs(%{{.+}} : tensor<1x1x2x2xf32>) -> tensor<1x1x2x2xf32>

func.func @pooling_nchw_max_tensor(%input: tensor<1x1x4x4xf32>) -> tensor<1x1x2x2xf32> {
  %fake = tensor.empty() : tensor<3x3xf32>
  %init = tensor.empty() : tensor<1x1x2x2xf32>
  %cst = arith.constant 0.000000e+00 : f32
  %fill = linalg.fill ins(%cst : f32) outs(%init : tensor<1x1x2x2xf32>) -> tensor<1x1x2x2xf32>
  %res = linalg.pooling_nchw_max {dilations = dense<1> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>}
    ins(%input, %fake: tensor<1x1x4x4xf32>, tensor<3x3xf32>)
    outs(%fill: tensor<1x1x2x2xf32>) -> tensor<1x1x2x2xf32>
  return %res : tensor<1x1x2x2xf32>
}

// -----
// CHECK-LABEL: func @pooling_ncw_max_tensor
// CHECK:         %{{.+}} = linalg.pooling_ncw_max
// CHECK-SAME:      dilations = dense<1> : tensor<1xi64>
// CHECK-SAME:      strides = dense<1> : tensor<1xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : tensor<1x1x4xf32>, tensor<3xf32>)
// CHECK-SAME:      outs(%{{.+}} : tensor<1x1x2xf32>) -> tensor<1x1x2xf32>

func.func @pooling_ncw_max_tensor(%input: tensor<1x1x4xf32>) -> tensor<1x1x2xf32> {
  %fake = tensor.empty() : tensor<3xf32>
  %init = tensor.empty() : tensor<1x1x2xf32>
  %cst = arith.constant 0.000000e+00 : f32
  %fill = linalg.fill ins(%cst : f32) outs(%init : tensor<1x1x2xf32>) -> tensor<1x1x2xf32>
  %res = linalg.pooling_ncw_max {dilations = dense<1> : tensor<1xi64>, strides = dense<1> : tensor<1xi64>}
    ins(%input, %fake: tensor<1x1x4xf32>, tensor<3xf32>)
    outs(%fill: tensor<1x1x2xf32>) -> tensor<1x1x2xf32>
  return %res : tensor<1x1x2xf32>
}

// -----

// CHECK-LABEL: func @pooling_nhwc_max
// CHECK:         linalg.pooling_nhwc_max
// CHECK-SAME:      dilations = dense<1> : tensor<2xi64>
// CHECK-SAME:      strides = dense<1> : tensor<2xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : memref<1x4x4x1xf32>, memref<3x3xf32>)
// CHECK-SAME:      outs(%{{.+}} : memref<1x2x2x1xf32>)
func.func @pooling_nhwc_max(%input: memref<1x4x4x1xf32>, %fake: memref<3x3xf32>, %output: memref<1x2x2x1xf32>) {
  linalg.pooling_nhwc_max {dilations = dense<1> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>}
    ins(%input, %fake: memref<1x4x4x1xf32>, memref<3x3xf32>)
    outs(%output: memref<1x2x2x1xf32>)
  return
}

// -----

// CHECK-LABEL: func @pooling_nwc_max
// CHECK:         linalg.pooling_nwc_max
// CHECK-SAME:      dilations = dense<1> : tensor<1xi64>
// CHECK-SAME:      strides = dense<1> : tensor<1xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : memref<1x4x1xf32>, memref<3xf32>)
// CHECK-SAME:      outs(%{{.+}} : memref<1x2x1xf32>)
func.func @pooling_nwc_max(%input: memref<1x4x1xf32>, %fake: memref<3xf32>, %output: memref<1x2x1xf32>) {
  linalg.pooling_nwc_max {dilations = dense<1> : tensor<1xi64>, strides = dense<1> : tensor<1xi64>}
    ins(%input, %fake: memref<1x4x1xf32>, memref<3xf32>)
    outs(%output: memref<1x2x1xf32>)
  return
}

// -----

// CHECK-LABEL: func @pooling_nhwc_i8_max_tensor
// CHECK:         %{{.+}} = linalg.pooling_nhwc_max
// CHECK-SAME:      dilations = dense<1> : tensor<2xi64>
// CHECK-SAME:      strides = dense<1> : tensor<2xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : tensor<1x4x4x1xi8>, tensor<3x3xi8>)
// CHECK-SAME:      outs(%{{.+}} : tensor<1x2x2x1xi8>) -> tensor<1x2x2x1xi8>
func.func @pooling_nhwc_i8_max_tensor(%input: tensor<1x4x4x1xi8>) -> tensor<1x2x2x1xi8> {
  %fake = tensor.empty() : tensor<3x3xi8>
  %init = tensor.empty() : tensor<1x2x2x1xi8>
  %cst = arith.constant 0 : i8
  %fill = linalg.fill ins(%cst : i8) outs(%init : tensor<1x2x2x1xi8>) -> tensor<1x2x2x1xi8>
  %res = linalg.pooling_nhwc_max {dilations = dense<1> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>}
    ins(%input, %fake: tensor<1x4x4x1xi8>, tensor<3x3xi8>)
    outs(%fill: tensor<1x2x2x1xi8>) -> tensor<1x2x2x1xi8>
  return %res : tensor<1x2x2x1xi8>
}

// -----

// CHECK-LABEL: func @pooling_nwc_i8_max_tensor
// CHECK:         %{{.+}} = linalg.pooling_nwc_max
// CHECK-SAME:      dilations = dense<1> : tensor<1xi64>
// CHECK-SAME:      strides = dense<1> : tensor<1xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : tensor<1x4x1xi8>, tensor<3xi8>)
// CHECK-SAME:      outs(%{{.+}} : tensor<1x2x1xi8>) -> tensor<1x2x1xi8>
func.func @pooling_nwc_i8_max_tensor(%input: tensor<1x4x1xi8>) -> tensor<1x2x1xi8> {
  %fake = tensor.empty() : tensor<3xi8>
  %init = tensor.empty() : tensor<1x2x1xi8>
  %cst = arith.constant 0 : i8
  %fill = linalg.fill ins(%cst : i8) outs(%init : tensor<1x2x1xi8>) -> tensor<1x2x1xi8>
  %res = linalg.pooling_nwc_max {dilations = dense<1> : tensor<1xi64>, strides = dense<1> : tensor<1xi64>}
    ins(%input, %fake: tensor<1x4x1xi8>, tensor<3xi8>)
    outs(%fill: tensor<1x2x1xi8>) -> tensor<1x2x1xi8>
  return %res : tensor<1x2x1xi8>
}

// -----

// CHECK-LABEL: func @pooling_nhwc_i8_max
// CHECK:         linalg.pooling_nhwc_max
// CHECK-SAME:      dilations = dense<1> : tensor<2xi64>
// CHECK-SAME:      strides = dense<1> : tensor<2xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : memref<1x4x4x1xi8>, memref<3x3xi8>)
// CHECK-SAME:      outs(%{{.+}} : memref<1x2x2x1xi8>)
func.func @pooling_nhwc_i8_max(%input: memref<1x4x4x1xi8>, %fake: memref<3x3xi8>, %output: memref<1x2x2x1xi8>) {
  linalg.pooling_nhwc_max {dilations = dense<1> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>}
    ins(%input, %fake: memref<1x4x4x1xi8>, memref<3x3xi8>)
    outs(%output: memref<1x2x2x1xi8>)
  return
}

// -----

// CHECK-LABEL: func @pooling_nwc_i8_max
// CHECK:         linalg.pooling_nwc_max
// CHECK-SAME:      dilations = dense<1> : tensor<1xi64>
// CHECK-SAME:      strides = dense<1> : tensor<1xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : memref<1x4x1xi8>, memref<3xi8>)
// CHECK-SAME:      outs(%{{.+}} : memref<1x2x1xi8>)
func.func @pooling_nwc_i8_max(%input: memref<1x4x1xi8>, %fake: memref<3xi8>, %output: memref<1x2x1xi8>) {
  linalg.pooling_nwc_max {dilations = dense<1> : tensor<1xi64>, strides = dense<1> : tensor<1xi64>}
    ins(%input, %fake: memref<1x4x1xi8>, memref<3xi8>)
    outs(%output: memref<1x2x1xi8>)
  return
}

// -----

// CHECK-LABEL: func @pooling_nhwc_i16_max_tensor
// CHECK:         %{{.+}} = linalg.pooling_nhwc_max
// CHECK-SAME:      dilations = dense<1> : tensor<2xi64>
// CHECK-SAME:      strides = dense<1> : tensor<2xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : tensor<1x4x4x1xi16>, tensor<3x3xi16>)
// CHECK-SAME:      outs(%{{.+}} : tensor<1x2x2x1xi16>) -> tensor<1x2x2x1xi16>
func.func @pooling_nhwc_i16_max_tensor(%input: tensor<1x4x4x1xi16>) -> tensor<1x2x2x1xi16> {
  %fake = tensor.empty() : tensor<3x3xi16>
  %init = tensor.empty() : tensor<1x2x2x1xi16>
  %cst = arith.constant 0 : i16
  %fill = linalg.fill ins(%cst : i16) outs(%init : tensor<1x2x2x1xi16>) -> tensor<1x2x2x1xi16>
  %res = linalg.pooling_nhwc_max {dilations = dense<1> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>}
    ins(%input, %fake: tensor<1x4x4x1xi16>, tensor<3x3xi16>)
    outs(%fill: tensor<1x2x2x1xi16>) -> tensor<1x2x2x1xi16>
  return %res : tensor<1x2x2x1xi16>
}

// -----

// CHECK-LABEL: func @pooling_nwc_i16_max_tensor
// CHECK:         %{{.+}} = linalg.pooling_nwc_max
// CHECK-SAME:      dilations = dense<1> : tensor<1xi64>
// CHECK-SAME:      strides = dense<1> : tensor<1xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : tensor<1x4x1xi16>, tensor<3xi16>)
// CHECK-SAME:      outs(%{{.+}} : tensor<1x2x1xi16>) -> tensor<1x2x1xi16>
func.func @pooling_nwc_i16_max_tensor(%input: tensor<1x4x1xi16>) -> tensor<1x2x1xi16> {
  %fake = tensor.empty() : tensor<3xi16>
  %init = tensor.empty() : tensor<1x2x1xi16>
  %cst = arith.constant 0 : i16
  %fill = linalg.fill ins(%cst : i16) outs(%init : tensor<1x2x1xi16>) -> tensor<1x2x1xi16>
  %res = linalg.pooling_nwc_max {dilations = dense<1> : tensor<1xi64>, strides = dense<1> : tensor<1xi64>}
    ins(%input, %fake: tensor<1x4x1xi16>, tensor<3xi16>)
    outs(%fill: tensor<1x2x1xi16>) -> tensor<1x2x1xi16>
  return %res : tensor<1x2x1xi16>
}

// -----

// CHECK-LABEL: func @pooling_nhwc_i16_max
// CHECK:         linalg.pooling_nhwc_max
// CHECK-SAME:      dilations = dense<1> : tensor<2xi64>
// CHECK-SAME:      strides = dense<1> : tensor<2xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : memref<1x4x4x1xi16>, memref<3x3xi16>)
// CHECK-SAME:      outs(%{{.+}} : memref<1x2x2x1xi16>)
func.func @pooling_nhwc_i16_max(%input: memref<1x4x4x1xi16>, %fake: memref<3x3xi16>, %output: memref<1x2x2x1xi16>) {
  linalg.pooling_nhwc_max {dilations = dense<1> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>}
    ins(%input, %fake: memref<1x4x4x1xi16>, memref<3x3xi16>)
    outs(%output: memref<1x2x2x1xi16>)
  return
}

// -----

// CHECK-LABEL: func @pooling_nwc_i16_max
// CHECK:         linalg.pooling_nwc_max
// CHECK-SAME:      dilations = dense<1> : tensor<1xi64>
// CHECK-SAME:      strides = dense<1> : tensor<1xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : memref<1x4x1xi16>, memref<3xi16>)
// CHECK-SAME:      outs(%{{.+}} : memref<1x2x1xi16>)
func.func @pooling_nwc_i16_max(%input: memref<1x4x1xi16>, %fake: memref<3xi16>, %output: memref<1x2x1xi16>) {
  linalg.pooling_nwc_max {dilations = dense<1> : tensor<1xi64>, strides = dense<1> : tensor<1xi64>}
    ins(%input, %fake: memref<1x4x1xi16>, memref<3xi16>)
    outs(%output: memref<1x2x1xi16>)
  return
}

// -----

// CHECK-LABEL: func @pooling_nhwc_i32_max_tensor
// CHECK:         %{{.+}} = linalg.pooling_nhwc_max
// CHECK-SAME:      dilations = dense<1> : tensor<2xi64>
// CHECK-SAME:      strides = dense<1> : tensor<2xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : tensor<1x4x4x1xi32>, tensor<3x3xi32>)
// CHECK-SAME:      outs(%{{.+}} : tensor<1x2x2x1xi32>) -> tensor<1x2x2x1xi32>
func.func @pooling_nhwc_i32_max_tensor(%input: tensor<1x4x4x1xi32>) -> tensor<1x2x2x1xi32> {
  %fake = tensor.empty() : tensor<3x3xi32>
  %init = tensor.empty() : tensor<1x2x2x1xi32>
  %cst = arith.constant 0 : i32
  %fill = linalg.fill ins(%cst : i32) outs(%init : tensor<1x2x2x1xi32>) -> tensor<1x2x2x1xi32>
  %res = linalg.pooling_nhwc_max {dilations = dense<1> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>}
    ins(%input, %fake: tensor<1x4x4x1xi32>, tensor<3x3xi32>)
    outs(%fill: tensor<1x2x2x1xi32>) -> tensor<1x2x2x1xi32>
  return %res : tensor<1x2x2x1xi32>
}

// -----

// CHECK-LABEL: func @pooling_nwc_i32_max_tensor
// CHECK:         %{{.+}} = linalg.pooling_nwc_max
// CHECK-SAME:      dilations = dense<1> : tensor<1xi64>
// CHECK-SAME:      strides = dense<1> : tensor<1xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : tensor<1x4x1xi32>, tensor<3xi32>)
// CHECK-SAME:      outs(%{{.+}} : tensor<1x2x1xi32>) -> tensor<1x2x1xi32>
func.func @pooling_nwc_i32_max_tensor(%input: tensor<1x4x1xi32>) -> tensor<1x2x1xi32> {
  %fake = tensor.empty() : tensor<3xi32>
  %init = tensor.empty() : tensor<1x2x1xi32>
  %cst = arith.constant 0 : i32
  %fill = linalg.fill ins(%cst : i32) outs(%init : tensor<1x2x1xi32>) -> tensor<1x2x1xi32>
  %res = linalg.pooling_nwc_max {dilations = dense<1> : tensor<1xi64>, strides = dense<1> : tensor<1xi64>}
    ins(%input, %fake: tensor<1x4x1xi32>, tensor<3xi32>)
    outs(%fill: tensor<1x2x1xi32>) -> tensor<1x2x1xi32>
  return %res : tensor<1x2x1xi32>
}

// -----

// CHECK-LABEL: func @pooling_nhwc_i32_max
// CHECK:         linalg.pooling_nhwc_max
// CHECK-SAME:      dilations = dense<1> : tensor<2xi64>
// CHECK-SAME:      strides = dense<1> : tensor<2xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : memref<1x4x4x1xi32>, memref<3x3xi32>)
// CHECK-SAME:      outs(%{{.+}} : memref<1x2x2x1xi32>)
func.func @pooling_nhwc_i32_max(%input: memref<1x4x4x1xi32>, %fake: memref<3x3xi32>, %output: memref<1x2x2x1xi32>) {
  linalg.pooling_nhwc_max {dilations = dense<1> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>}
    ins(%input, %fake: memref<1x4x4x1xi32>, memref<3x3xi32>)
    outs(%output: memref<1x2x2x1xi32>)
  return
}

// -----

// CHECK-LABEL: func @pooling_nwc_i32_max
// CHECK:         linalg.pooling_nwc_max
// CHECK-SAME:      dilations = dense<1> : tensor<1xi64>
// CHECK-SAME:      strides = dense<1> : tensor<1xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : memref<1x4x1xi32>, memref<3xi32>)
// CHECK-SAME:      outs(%{{.+}} : memref<1x2x1xi32>)
func.func @pooling_nwc_i32_max(%input: memref<1x4x1xi32>, %fake: memref<3xi32>, %output: memref<1x2x1xi32>) {
  linalg.pooling_nwc_max {dilations = dense<1> : tensor<1xi64>, strides = dense<1> : tensor<1xi64>}
    ins(%input, %fake: memref<1x4x1xi32>, memref<3xi32>)
    outs(%output: memref<1x2x1xi32>)
  return
}


// -----

// CHECK-LABEL: func @pooling_nhwc_min_tensor
// CHECK:         %{{.+}} = linalg.pooling_nhwc_min
// CHECK-SAME:      dilations = dense<1> : tensor<2xi64>
// CHECK-SAME:      strides = dense<1> : tensor<2xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : tensor<1x4x4x1xf32>, tensor<3x3xf32>)
// CHECK-SAME:      outs(%{{.+}} : tensor<1x2x2x1xf32>) -> tensor<1x2x2x1xf32>
func.func @pooling_nhwc_min_tensor(%input: tensor<1x4x4x1xf32>) -> tensor<1x2x2x1xf32> {
  %fake = tensor.empty() : tensor<3x3xf32>
  %init = tensor.empty() : tensor<1x2x2x1xf32>
  %cst = arith.constant 0.000000e+00 : f32
  %fill = linalg.fill ins(%cst : f32) outs(%init : tensor<1x2x2x1xf32>) -> tensor<1x2x2x1xf32>
  %res = linalg.pooling_nhwc_min {dilations = dense<1> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>}
    ins(%input, %fake: tensor<1x4x4x1xf32>, tensor<3x3xf32>)
    outs(%fill: tensor<1x2x2x1xf32>) -> tensor<1x2x2x1xf32>
  return %res : tensor<1x2x2x1xf32>
}

// -----

// CHECK-LABEL: func @pooling_nwc_min_tensor
// CHECK:         %{{.+}} = linalg.pooling_nwc_min
// CHECK-SAME:      dilations = dense<1> : tensor<1xi64>
// CHECK-SAME:      strides = dense<1> : tensor<1xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : tensor<1x4x1xf32>, tensor<3xf32>)
// CHECK-SAME:      outs(%{{.+}} : tensor<1x2x1xf32>) -> tensor<1x2x1xf32>
func.func @pooling_nwc_min_tensor(%input: tensor<1x4x1xf32>) -> tensor<1x2x1xf32> {
  %fake = tensor.empty() : tensor<3xf32>
  %init = tensor.empty() : tensor<1x2x1xf32>
  %cst = arith.constant 0.000000e+00 : f32
  %fill = linalg.fill ins(%cst : f32) outs(%init : tensor<1x2x1xf32>) -> tensor<1x2x1xf32>
  %res = linalg.pooling_nwc_min {dilations = dense<1> : tensor<1xi64>, strides = dense<1> : tensor<1xi64>}
    ins(%input, %fake: tensor<1x4x1xf32>, tensor<3xf32>)
    outs(%fill: tensor<1x2x1xf32>) -> tensor<1x2x1xf32>
  return %res : tensor<1x2x1xf32>
}

// -----

// CHECK-LABEL: func @pooling_nhwc_min
// CHECK:         linalg.pooling_nhwc_min
// CHECK-SAME:      dilations = dense<1> : tensor<2xi64>
// CHECK-SAME:      strides = dense<1> : tensor<2xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : memref<1x4x4x1xf32>, memref<3x3xf32>)
// CHECK-SAME:      outs(%{{.+}} : memref<1x2x2x1xf32>)
func.func @pooling_nhwc_min(%input: memref<1x4x4x1xf32>, %fake: memref<3x3xf32>, %output: memref<1x2x2x1xf32>) {
  linalg.pooling_nhwc_min {dilations = dense<1> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>}
    ins(%input, %fake: memref<1x4x4x1xf32>, memref<3x3xf32>)
    outs(%output: memref<1x2x2x1xf32>)
  return
}

// -----

// CHECK-LABEL: func @pooling_nwc_min
// CHECK:         linalg.pooling_nwc_min
// CHECK-SAME:      dilations = dense<1> : tensor<1xi64>
// CHECK-SAME:      strides = dense<1> : tensor<1xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : memref<1x4x1xf32>, memref<3xf32>)
// CHECK-SAME:      outs(%{{.+}} : memref<1x2x1xf32>)
func.func @pooling_nwc_min(%input: memref<1x4x1xf32>, %fake: memref<3xf32>, %output: memref<1x2x1xf32>) {
  linalg.pooling_nwc_min {dilations = dense<1> : tensor<1xi64>, strides = dense<1> : tensor<1xi64>}
    ins(%input, %fake: memref<1x4x1xf32>, memref<3xf32>)
    outs(%output: memref<1x2x1xf32>)
  return
}

// -----

// CHECK-LABEL: func @pooling_ndhwc_sum_tensor
// CHECK:         %{{.+}} = linalg.pooling_ndhwc_sum
// CHECK-SAME:      dilations = dense<1> : tensor<3xi64>
// CHECK-SAME:      strides = dense<1> : tensor<3xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : tensor<1x4x4x4x1xf32>, tensor<3x3x3xf32>)
// CHECK-SAME:      outs(%{{.+}} : tensor<1x2x2x2x1xf32>) -> tensor<1x2x2x2x1xf32>
func.func @pooling_ndhwc_sum_tensor(%input: tensor<1x4x4x4x1xf32>) -> tensor<1x2x2x2x1xf32> {
  %fake = tensor.empty() : tensor<3x3x3xf32>
  %init = tensor.empty() : tensor<1x2x2x2x1xf32>
  %cst = arith.constant 0.000000e+00 : f32
  %fill = linalg.fill ins(%cst : f32) outs(%init : tensor<1x2x2x2x1xf32>) -> tensor<1x2x2x2x1xf32>
  %res = linalg.pooling_ndhwc_sum {dilations = dense<1> : tensor<3xi64>, strides = dense<1> : tensor<3xi64>}
    ins(%input, %fake: tensor<1x4x4x4x1xf32>, tensor<3x3x3xf32>)
    outs(%fill: tensor<1x2x2x2x1xf32>) -> tensor<1x2x2x2x1xf32>
  return %res : tensor<1x2x2x2x1xf32>
}

// -----

// CHECK-LABEL: func @pooling_ndhwc_sum
// CHECK:         linalg.pooling_ndhwc_sum
// CHECK-SAME:      dilations = dense<1> : tensor<3xi64>
// CHECK-SAME:      strides = dense<1> : tensor<3xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : memref<1x4x4x4x1xf32>, memref<3x3x3xf32>)
// CHECK-SAME:      outs(%{{.+}} : memref<1x2x2x2x1xf32>)
func.func @pooling_ndhwc_sum(%input: memref<1x4x4x4x1xf32>, %fake: memref<3x3x3xf32>, %output: memref<1x2x2x2x1xf32>) {
  linalg.pooling_ndhwc_sum {dilations = dense<1> : tensor<3xi64>, strides = dense<1> : tensor<3xi64>}
    ins(%input, %fake: memref<1x4x4x4x1xf32>, memref<3x3x3xf32>)
    outs(%output: memref<1x2x2x2x1xf32>)
  return
}

// -----

// CHECK-LABEL: func @pooling_ndhwc_max_tensor
// CHECK:         %{{.+}} = linalg.pooling_ndhwc_max
// CHECK-SAME:      dilations = dense<1> : tensor<3xi64>
// CHECK-SAME:      strides = dense<1> : tensor<3xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : tensor<1x4x4x4x1xf32>, tensor<3x3x3xf32>)
// CHECK-SAME:      outs(%{{.+}} : tensor<1x2x2x2x1xf32>) -> tensor<1x2x2x2x1xf32>
func.func @pooling_ndhwc_max_tensor(%input: tensor<1x4x4x4x1xf32>) -> tensor<1x2x2x2x1xf32> {
  %fake = tensor.empty() : tensor<3x3x3xf32>
  %init = tensor.empty() : tensor<1x2x2x2x1xf32>
  %cst = arith.constant 0.000000e+00 : f32
  %fill = linalg.fill ins(%cst : f32) outs(%init : tensor<1x2x2x2x1xf32>) -> tensor<1x2x2x2x1xf32>
  %res = linalg.pooling_ndhwc_max {dilations = dense<1> : tensor<3xi64>, strides = dense<1> : tensor<3xi64>}
    ins(%input, %fake: tensor<1x4x4x4x1xf32>, tensor<3x3x3xf32>)
    outs(%fill: tensor<1x2x2x2x1xf32>) -> tensor<1x2x2x2x1xf32>
  return %res : tensor<1x2x2x2x1xf32>
}

// -----

// CHECK-LABEL: func @pooling_ndhwc_max
// CHECK:         linalg.pooling_ndhwc_max
// CHECK-SAME:      dilations = dense<1> : tensor<3xi64>
// CHECK-SAME:      strides = dense<1> : tensor<3xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : memref<1x4x4x4x1xf32>, memref<3x3x3xf32>)
// CHECK-SAME:      outs(%{{.+}} : memref<1x2x2x2x1xf32>)
func.func @pooling_ndhwc_max(%input: memref<1x4x4x4x1xf32>, %fake: memref<3x3x3xf32>, %output: memref<1x2x2x2x1xf32>) {
  linalg.pooling_ndhwc_max {dilations = dense<1> : tensor<3xi64>, strides = dense<1> : tensor<3xi64>}
    ins(%input, %fake: memref<1x4x4x4x1xf32>, memref<3x3x3xf32>)
    outs(%output: memref<1x2x2x2x1xf32>)
  return
}

// -----

// CHECK-LABEL: func @pooling_ndhwc_min_tensor
// CHECK:         %{{.+}} = linalg.pooling_ndhwc_min
// CHECK-SAME:      dilations = dense<1> : tensor<3xi64>
// CHECK-SAME:      strides = dense<1> : tensor<3xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : tensor<1x4x4x4x1xf32>, tensor<3x3x3xf32>)
// CHECK-SAME:      outs(%{{.+}} : tensor<1x2x2x2x1xf32>) -> tensor<1x2x2x2x1xf32>
func.func @pooling_ndhwc_min_tensor(%input: tensor<1x4x4x4x1xf32>) -> tensor<1x2x2x2x1xf32> {
  %fake = tensor.empty() : tensor<3x3x3xf32>
  %init = tensor.empty() : tensor<1x2x2x2x1xf32>
  %cst = arith.constant 0.000000e+00 : f32
  %fill = linalg.fill ins(%cst : f32) outs(%init : tensor<1x2x2x2x1xf32>) -> tensor<1x2x2x2x1xf32>
  %res = linalg.pooling_ndhwc_min {dilations = dense<1> : tensor<3xi64>, strides = dense<1> : tensor<3xi64>}
    ins(%input, %fake: tensor<1x4x4x4x1xf32>, tensor<3x3x3xf32>)
    outs(%fill: tensor<1x2x2x2x1xf32>) -> tensor<1x2x2x2x1xf32>
  return %res : tensor<1x2x2x2x1xf32>
}

// -----

// CHECK-LABEL: func @pooling_ndhwc_min
// CHECK:         linalg.pooling_ndhwc_min
// CHECK-SAME:      dilations = dense<1> : tensor<3xi64>
// CHECK-SAME:      strides = dense<1> : tensor<3xi64>
// CHECK-SAME:      ins(%{{.+}}, %{{.+}} : memref<1x4x4x4x1xf32>, memref<3x3x3xf32>)
// CHECK-SAME:      outs(%{{.+}} : memref<1x2x2x2x1xf32>)
func.func @pooling_ndhwc_min(%input: memref<1x4x4x4x1xf32>, %fake: memref<3x3x3xf32>, %output: memref<1x2x2x2x1xf32>) {
  linalg.pooling_ndhwc_min {dilations = dense<1> : tensor<3xi64>, strides = dense<1> : tensor<3xi64>}
    ins(%input, %fake: memref<1x4x4x4x1xf32>, memref<3x3x3xf32>)
    outs(%output: memref<1x2x2x2x1xf32>)
  return
}

// -----

#map0 = affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d0, d1 * 2, d2 * 2 + d5, d6)>
#map1 = affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d4, d5, d6, d3)>
#map2 = affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d0, d1, d2, d3)>
func.func @conv_interface_wrong_input_indexing_map(
    %arg0 : tensor<?x?x?x?xf32>, %arg2 : tensor<?x?x?x?xf32>, %arg1 : tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32> {
  // expected-error @+1 {{unexpected input index map for convolutions}}
  %0 = "linalg.conv_2d_nhwc_hwcf"(%arg0, %arg1, %arg2) ({
    ^bb0(%arg3: f32, %arg4: f32, %arg5 : f32):
      %1 = "arith.mulf"(%arg3, %arg4) : (f32, f32) -> f32
      %2 = "arith.addf"(%arg5, %1) : (f32, f32) -> f32
      "linalg.yield"(%2) : (f32) -> ()
    }) {dilations = dense<1> : tensor<2xi64>, linalg.memoized_indexing_maps = [#map0, #map1, #map2], operand_segment_sizes = array<i32: 2, 1>, strides = dense<2> : tensor<2xi64>} : (tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>, tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
  return %0 : tensor<?x?x?x?xf32>
}

// -----

#map0 = affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d0, d1 + d4, d2 + d5, d6)>
#map1 = affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d4, d5, d6, d3, d5 + 1)>
#map2 = affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d0, d1, d2, d3)>
func.func @conv_interface_wrong_num_operands(
    %arg0 : tensor<?x?x?x?xf32>, %arg1 : tensor<?x?x?x?x?xf32>, %arg2 : tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32> {
  // expected-error @+1 {{expected output/filter indexing maps to be projected permutations}}
  %0 = "linalg.conv_2d_nhwc_hwcf"(%arg0, %arg1, %arg2) ({
    ^bb0(%arg3: f32, %arg4: f32, %arg5 : f32):
      %1 = "arith.mulf"(%arg3, %arg4) : (f32, f32) -> f32
      %2 = "arith.addf"(%arg5, %1) : (f32, f32) -> f32
      "linalg.yield"(%2) : (f32) -> ()
    }) {dilations = dense<1> : tensor<2xi64>, linalg.memoized_indexing_maps = [#map0, #map1, #map2], operand_segment_sizes = array<i32: 2, 1>, strides = dense<1> : tensor<2xi64>} : (tensor<?x?x?x?xf32>, tensor<?x?x?x?x?xf32>, tensor<?x?x?x?xf32>) -> tensor<?x?x?x?xf32>
  return %0 : tensor<?x?x?x?xf32>
}

// -----

func.func @batch_reduce_matmul(%arg0: tensor<8x128x256xf32>, %arg1: tensor<8x256x512xf32>, %arg2: tensor<128x512xf32>) -> tensor<128x512xf32> {
  // CHECK: %{{.+}} = linalg.batch_reduce_matmul
  // CHECK-SAME: ins(%{{.+}}, %{{.+}} : tensor<8x128x256xf32>, tensor<8x256x512xf32>)
  // CHECK-SAME: outs(%{{.+}} : tensor<128x512xf32>) -> tensor<128x512xf32>
  %0 = linalg.batch_reduce_matmul ins(%arg0, %arg1 : tensor<8x128x256xf32>, tensor<8x256x512xf32>) outs(%arg2: tensor<128x512xf32>) -> tensor<128x512xf32>
  return %0: tensor<128x512xf32>
}

// -----

func.func @batch_reduce_matmul(%arg0: memref<?x?x?xf32>, %arg1: memref<?x?x?xf32>, %arg2: memref<?x?xf32>) {
  // CHECK: linalg.batch_reduce_matmul
  // CHECK-SAME: ins(%{{.+}}, %{{.+}} : memref<?x?x?xf32>, memref<?x?x?xf32>)
  // CHECK-SAME: outs(%{{.+}} : memref<?x?xf32>)
  linalg.batch_reduce_matmul ins(%arg0, %arg1 : memref<?x?x?xf32>, memref<?x?x?xf32>) outs(%arg2: memref<?x?xf32>)
  return
}

// -----

// CHECK-LABEL: func @matmul_transpose_b
//       CHECK:   linalg.matmul_transpose_b
//  CHECK-SAME:     ins(%{{.+}}, %{{.+}} : memref<3x5xf32>, memref<7x5xf32>)
//  CHECK-SAME:     outs(%{{.+}} : memref<3x7xf32>)
func.func @matmul_transpose_b(%arg0: memref<3x5xf32>, %arg1: memref<7x5xf32>, %arg2: memref<3x7xf32>) {
  linalg.matmul_transpose_b ins(%arg0, %arg1 : memref<3x5xf32>, memref<7x5xf32>) outs(%arg2: memref<3x7xf32>)
  return
}

// -----

// CHECK-LABEL: func @batchmatmul_transpose_b
//       CHECK:   linalg.batch_matmul_transpose_b
//  CHECK-SAME:     ins(%{{.+}}, %{{.+}} : memref<2x3x5xf32>, memref<2x7x5xf32>)
//  CHECK-SAME:     outs(%{{.+}} : memref<2x3x7xf32>)
func.func @batchmatmul_transpose_b(%arg0: memref<2x3x5xf32>, %arg1: memref<2x7x5xf32>, %arg2: memref<2x3x7xf32>) {
  linalg.batch_matmul_transpose_b ins(%arg0, %arg1 : memref<2x3x5xf32>, memref<2x7x5xf32>) outs(%arg2: memref<2x3x7xf32>)
  return
}
