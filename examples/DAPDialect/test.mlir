//===- BuddyBiquad.mlir ---------------------------------------------------===//
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//===----------------------------------------------------------------------===//
//
// This file provides the MLIR Biquad IIR function.
//
//===----------------------------------------------------------------------===//

memref.global "private" @kernel_1 : memref<1x6xf32> = dense<[[0.00384314, 0.00768629, 0.00384314, 1.0, -1.78151, 0.796882]]>
memref.global "private" @kernel_2 : memref<2x6xf32> = dense<[[1.50711e-05, 3.01422e-05, 1.50711e-05, 1.0, -1.77501, 0.78867],
                                                             [1.0, 2., 1., 1., -1.82441, 0.842064]]>
memref.global "private" @kernel_3 : memref<1x6xf32> = dense<[[1., 1., 1., 1., 1., 1.]]>
memref.global "private" @kernel_4 : memref<2x6xf32> = dense<[[1., 1., 1., 1., 1., 1.],[1., 1., 1., 1., 1., 1.]]>
memref.global "private" @kernel_5 : memref<2x6xf32> = dense<[[1.50711e-05, 3.01422e-05, 1.50711e-05, 1.0, 0., 0.],
                                                             [1.0, 2., 1., 1., 0., 0.]]>

memref.global "private" @input_audio : memref<200xf32> = dense<[-0.0294185,-0.0294533,-0.0294744,-0.0294923,-0.0295035,-0.0295001,-0.0294832,-0.0294634,-0.0294336,-0.0294009,-0.0293614,-0.029314,-0.0292609,-0.0291925,-0.0291172,-0.0290308,-0.0289339,-0.0288329,-0.0287175,-0.0285955,-0.0284629,-0.0283229,-0.0281726,-0.0280143,-0.0278487,-0.0276719,-0.0274849,-0.0272905,-0.027082,-0.0268629,-0.0266413,-0.0264125,-0.026174,-0.0259287,-0.0256774,-0.0254159,-0.025141,-0.0248635,-0.0245768,-0.0242845,-0.0239828,-0.0236751,-0.0233588,-0.0230367,-0.0227096,-0.0223776,-0.022038,-0.0216935,-0.0213375,-0.0209779,-0.0206107,-0.0202354,-0.0198537,-0.0194725,-0.0190883,-0.0187014,-0.0183089,-0.0179217,-0.0175173,-0.0171114,-0.0167042,-0.016291,-0.0158695,-0.0154507,-0.0150317,-0.0146046,-0.0141746,-0.0137444,-0.0133077,-0.0128802,-0.0124545,-0.0120221,-0.0115887,-0.011161,-0.0107355,-0.0103085,-0.00988102,-0.00946045,-0.00902867,-0.0086056,-0.00818741,-0.00776911,-0.00735211,-0.00694358,-0.00654066,-0.00613558,-0.00573373,-0.00534189,-0.00495327,-0.00456739,-0.00418854,-0.00381684,-0.00345004,-0.00308681,-0.00273609,-0.00238526,-0.00203943,-0.00171399,-0.00139058,-0.00107729,-0.000766397,-0.000464916,-0.000170112,0.00011158,0.000383139,0.000652075,0.000917316,0.00116384,0.00139439,0.00163031,0.00185907,0.00207722,0.00228691,0.0024811,0.00266337,0.00284207,0.00300837,0.00315952,0.00330174,0.00343132,0.00355196,0.00366473,0.00376868,0.00386143,0.00394237,0.00401533,0.00407922,0.00412703,0.00417006,0.00420499,0.00423205,0.00424409,0.00424755,0.00423956,0.00421965,0.00419211,0.00415278,0.00409901,0.00404167,0.00397301,0.00389695,0.00381064,0.00372112,0.00362635,0.00352204,0.00341225,0.00329614,0.00316691,0.00303555,0.00288689,0.00273347,0.0025723,0.00241017,0.0022366,0.00205529,0.00187445,0.00169015,0.00149584,0.0013026,0.00110316,0.000901699,0.000695229,0.000482917,0.000270605,5.80549e-05,-0.000158548,-0.000375748,-0.000595927,-0.000812054,-0.00103533,-0.001261,-0.00148833,-0.00171006,-0.00192857,-0.00215232,-0.00237656,-0.00259757,-0.00282168,-0.00303781,-0.00324512,-0.00345159,-0.00365603,-0.00385511,-0.00405526,-0.00424457,-0.00442684,-0.00460291,-0.00477922,-0.00497699,-0.00514197,-0.0052942,-0.00544477,-0.00558257,-0.00571847,-0.00584447,-0.00596416,-0.00606978,-0.006176,-0.00625563,-0.00631213]>
memref.global "private" @input_audio2 : memref<20xf32> = dense<[-0.0294185,-0.0294533,-0.0294744,-0.0294923,-0.0295035,-0.0295001,-0.0294832,-0.0294634,-0.0294336,-0.0294009,-0.0293614,-0.029314,-0.0292609,-0.0291925,-0.0291172,-0.0290308,-0.0289339,-0.0288329,-0.0287175,-0.0285955]>
memref.global "private" @input_audio3 : memref<20xf32> = dense<1.0>

func.func @MLIR_iir(%in : memref<?xf32>, %filter : memref<?x?xf32>, %out : memref<?xf32>){
  %c0 = arith.constant 0 : index
  %N = memref.dim %in, %c0 : memref<?xf32>
  %M = memref.dim %filter, %c0: memref<?x?xf32>

  affine.for %j = 0 to %M iter_args(%inpt = %in) -> (memref<?xf32>){
    %b0 = affine.load %filter[%j, 0] : memref<?x?xf32>
    %b1 = affine.load %filter[%j, 1] : memref<?x?xf32>
    %b2 = affine.load %filter[%j, 2] : memref<?x?xf32>
    %a0 = affine.load %filter[%j, 3] : memref<?x?xf32>
    %a1 = affine.load %filter[%j, 4] : memref<?x?xf32>
    %a2 = affine.load %filter[%j, 5] : memref<?x?xf32>
    %init_z1 = arith.constant 0.0 : f32
    %init_z2 = arith.constant 0.0 : f32
    %res:2 = affine.for %i = 0 to %N iter_args(%z1 = %init_z1, %z2 = %init_z2) -> (f32, f32) {
        %input = affine.load %inpt[%i] : memref<?xf32>
        %t0 = arith.mulf %b0, %input : f32
        %output = arith.addf %t0, %z1 : f32

        %t1 = arith.mulf %b1, %input : f32
        %t2 = arith.mulf %a1, %output : f32
        %t3 = arith.subf %t1, %t2 : f32
        %z1_next = arith.addf %z2, %t3 : f32

        %t4 = arith.mulf %b2, %input : f32
        %t5 = arith.mulf %a2, %output : f32
        %z2_next = arith.subf %t4, %t5 : f32
        
        affine.store %output, %out[%i] : memref<?xf32>
        affine.yield %z1_next, %z2_next : f32, f32
    }
    affine.yield %out : memref<?xf32>
  }
  return
}

// func.func @buddy_iir(%in : memref<?xf32>, %filter : memref<?x?xf32>, %out : memref<?xf32>) -> () {
//   dap.iir %in, %filter, %out : memref<?xf32>, memref<?x?xf32>, memref<?xf32>
//   return
// } 

func.func @main() -> () {
  %krn0 = memref.get_global @kernel_5 : memref<2x6xf32>
  %data0 = memref.get_global @input_audio3 : memref<20xf32>
  %output0 = memref.alloc() : memref<20xf32>
  %krn = memref.cast %krn0 : memref<2x6xf32> to memref<?x?xf32>
  %data = memref.cast %data0: memref<20xf32> to memref<?xf32>
  %output = memref.cast %output0: memref<20xf32> to memref<?xf32>
//   func.call @MLIR_iir(%data, %krn, %output) : (memref<?xf32>, memref<?x?xf32>, memref<?xf32>) -> ()
  dap.iir %data, %krn, %output : memref<?xf32>, memref<?x?xf32>, memref<?xf32>
  return
}