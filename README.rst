constant_rebuilds
=================

Thie project reproduced the problem of external project always rebuilding when using Visual Studio 2019.

How to reproduce:

1. Open an ``x64 Native Tools Command prompt for VS 2019``
#. Run ``generate-vs19.bat``
#. Open the solution ``vs19-win64-build/constant_rebuilds.sln`` in VS 2019
#. Build solution
#. Build solution one more time.

When performing the same steps using ``generate-vs17.bat``, the second build doesn't do anything.
