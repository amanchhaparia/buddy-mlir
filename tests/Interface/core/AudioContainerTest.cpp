//===- AudioContainerTest.cpp ---------------------------------------------===//
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
// This is the audio container test file.
//
//===----------------------------------------------------------------------===//

// RUN: buddy-audio-container-test 2>&1 | FileCheck %s

#include "Interface/buddy/dap/AudioContainer.h"
#include <iostream>
#include <kfr/base.hpp>
#include <kfr/dft.hpp>
#include <kfr/dsp.hpp>
#include <kfr/io.hpp>

using namespace std;
using namespace kfr;

int main() {
  dap::Audio<float, 1> aud("../../tests/Interface/core/NASA_Mars.wav");
  auto &audioFile = aud.getAudioFile();
  // CHECK: 1
  fprintf(stderr, "%u\n", audioFile.getNumChannels());
  // CHECK: 24
  fprintf(stderr, "%u\n", audioFile.getBitDepth());
  // CHECK: 2000000
  fprintf(stderr, "%u\n", audioFile.getNumSamplesPerChannel());
  // CHECK: 100000
  fprintf(stderr, "%u\n", audioFile.getSampleRate());

  float data[] =  {0.05, 2.06, 4.05, 100.06, 20000.888, -0.05, -2.06, -4.05, -100.06, -20000.888};
  int size = sizeof(data)/sizeof(data[0]);

  univector<float> data_kfr(data, data+size);

  cout<<"---------------------RAW DATA--------------------------\n";
  for(int i=0; i<size; i++){
    cout<<data_kfr[i]<<", ";
  }
  cout<<"\n \n";

  // Save data using Buddy Audio Container
  dap:: Audio<float, 1>output;
  output.getAudioFile().setBitDepth(24);
  output.getAudioFile().setSampleRate(100000);
  output.getAudioFile().numChannels = 1;
  output.getAudioFile().numSamples = size;
  output.getAudioFile().setAudioBuffer(data);
  
  output.save("Test_Output.wav");

  // Read and output the encoded values.
  dap:: Audio<float, 1> aud_read("Test_Output.wav");
  auto &audioFileRead = aud_read.getAudioFile();

  cout<<"-----------BUDDY AUDIO CONTAINER ENCODED---------------\n";
  for(int i=0; i<size; i++){
    cout<<audioFileRead.samples.get()[i]<<", ";
  }
  cout<<"\n \n";
  
  // Save data using KFR Audio writer
  audio_writer_wav<float> writer(
        open_file_for_writing("Test_Output_kfr.wav"),
        audio_format{1 /* channel */, audio_sample_type::i24,
                    100000 /* sample rate */});

  writer.write(data_kfr.data(), data_kfr.size());
  writer.close();

  // Read and output the KFR encoded values.
  dap:: Audio<float, 1> kfr_aud_read("Test_Output_kfr.wav");
  auto &kfrAudioRead = kfr_aud_read.getAudioFile();

  cout<<"-----------KFR AUDIO ENCODED---------------\n";
  for(int i=0; i<size; i++){
    cout<<kfrAudioRead.samples.get()[i]<<", ";
  }
  cout<<"\n";

  return 0;
}
