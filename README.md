# symbs

NOTE: Right now **symbs** is not operative due to lack of time to fix
the existing bugs. It once worked when doing my master but today it is
here as an convenient personal archive.

Automatic generation of equations of motion for constrained multibody
systems in 2D using symbolic manipulation.

**symbs** uses Octave's or Matlab's symbolic manipulation functionalities
to create C++ code for the equation of motion of a given multibody system
description. There are 3 formulations available:
	* Classical Newton-Euler equations which gives a DAE of index 3
	* Newton-Euler equations with reduced index which gives DAE of index 1
	* D'Alembert formulation which gives a ODE in generalized coordinates.

## Prerequisites

	1. A running version of Octave (v4.0 or later) or Matlab
	(tested under v9.2) with their appropriete symbolic package.
	2. (Optional) if you plan to use the built-in linear solver you must
	have [Eigen](http://eigen.tuxfamily.org/index.php?title=Main_Page),
	a non updated copy is provided under the directory extern.
	3. (Optional) if you plan to use the built-in ODE integrator you must
	have [Odeint] (http://headmyshoulder.github.io/odeint-v2/) installed.
	Odeint is part of Boost numeric

### Installing

Donwload **symbs** to directory of your choice and add the matlab source
path in Octave or Matlab.

Example in Octave:
	addpath('/home/username/symbs/octave');
	include_octave;

Example in Matlab:
	addpath('/home/username/symbs/octave');
