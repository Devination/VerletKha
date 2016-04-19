# VerletKha
A simple Verlet (pronounced 'ver-ley') physics engine written in Haxe and Kha. Port of [verlet-js](http://subprotocol.com/system/introducing-verlet-js.html) with some references taken from [verlet-js-unity](https://github.com/Magd3v/verlet-js-unity)

![Tire](https://lh4.googleusercontent.com/-4WirsEC5qfc/VxRRD9JEs0I/AAAAAAAAB0g/gzPgE0SglS0K7cKToBCsDB73RedfQivcwCL0B/w350-h282-no/VerletTire.gif) ![Collision](https://1.bp.blogspot.com/-sZOCXiklNMA/VxXvK8lH5-I/AAAAAAAAB2o/6u0v4LKl5vwVSx9PfaqZMOi_H24XTrPJgCLcB/s320/CircleCollision.gif)

Particles, distance constraints, and angular constraints are all supported. From these primitives it is possible to construct just about anything you can imagine.

How to use
--------
Add to your Kha project's Libraries folder via cloning, adding as a submodule, or downloading directly. I usually go with 
```
git submodule add https://github.com/Devination/VerletKha.git Libraries/verlet/
``` 
Then when I need to update the submodule I'll use
```
git submodule foreach --recursive git checkout master && git submodule foreach --recursive git pull origin master
``` 
Documentation forthcoming. In the mean time, check out the Demos and their source code below.

Demos
--------
1. [Shapes (VerletKha Hello world)](http://www.devination.com/p/verletkha-shapes.html) - [Source Code](https://github.com/Devination/VerletKha-Examples/tree/master/Shapes)
2. [Collision Primitives](http://www.devination.com/2016/04/verletkha-collision-primitives.html) - [Source Code](https://github.com/Devination/VerletKha-Examples/tree/master/Collision)

TODO
-------
1. Documentation
2. Collision Shapes
3. [Other things that'd be nice to have](https://trello.com/b/Uh63UCJi/verletkha)

License
-------
You may use VerletKha under the terms of the MIT License (See [LICENSE](LICENSE)).
