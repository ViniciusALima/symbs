% Check`s if the environment is Octave.
%
% @author: Vinicius de A. Lima
% @date: 2018-10-26


% This file is part of symbs.
%
% symbs is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% symbs is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with symbs.  If not, see <https://www.gnu.org/licenses/>.

function retval = is_octave
% is_octave Returns true if the environment is Octave.
  persistent cacheval;  % speeds up repeated calls
  if isempty (cacheval)
    cacheval = (exist ("OCTAVE_VERSION", "builtin") > 0);
  end
  retval = cacheval;
end
