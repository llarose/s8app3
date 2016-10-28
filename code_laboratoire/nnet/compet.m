## Copyright (c) 2014, Simon Brodeur
## All rights reserved.
## 
## Redistribution and use in source and binary forms, with or without modification,
## are permitted provided that the following conditions are met:
## 
##  - Redistributions of source code must retain the above copyright notice, 
##    this list of conditions and the following disclaimer.
##  - Redistributions in binary form must reproduce the above copyright notice, 
##    this list of conditions and the following disclaimer in the documentation 
##    and/or other materials provided with the distribution.
##  - Neither the name of Simon Brodeur nor the names of its contributors 
##    may be used to endorse or promote products derived from this software 
##    without specific prior written permission.
## 
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
## ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
## WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
## IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
## INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT 
## NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
## OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
## WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
## ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
## POSSIBILITY OF SUCH DAMAGE.
##

## Author: Simon Brodeur <simon.brodeur@usherbrooke.ca>
## Université de Sherbrooke, APP3 S8GIA, A2014
## Octave 3.8.2

## usage: A = compet(N)
##
## Competition operator that selects only the highest-valued dimension for 
## a vector or matrix (applied row-wise). The function returns a binary mask.
## This is useful in neural network applications to select the strongest output 
## neuron (set value as 1) and supress the activities of the other 
## neurons (set values as 0).
##
## Input:
## - N, a single row vector. If a matrix is provided, the thresholding 
##   is performed independently for each row.
##
## Output:
##
## - A, a binary vector or matrix of the same dimension as N.
##
## Example:
##
## n = [1,2,3; 
##      6,5,4; 
##      7,9,8];
## a = compet(n)
## ans =
##    0   0   1
##    1   0   0
##    0   1   0
function a = compet(n)
  n = n';
  a = zeros(size(n));
  a(find(n == repmat(max(n),size(n,1),1))) = 1;
  a = a';
endfunction
