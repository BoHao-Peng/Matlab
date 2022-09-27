# Matlab Code
## Coordinate Rotation
### [CorRotate.m](https://github.com/BoHao-Peng/Matlab/blob/main/Coordinate%20Rotation/CorRotate.m)
This code is based on [Eular's Rotation Theorem](https://en.wikipedia.org/wiki/Euler%27s_rotation_theorem), 
the direction of rotation is right-hand rule, and the rotation axis is limited to the X,Y,Z axis.
### [MyQuaternion.m](https://github.com/BoHao-Peng/Matlab/blob/main/Coordinate%20Rotation/MyQuaternion.m)
This is a ratation function using "Quaternion"
[[1]](https://www.youtube.com/watch?v=d4EgbgTm0Bg&ab_channel=3Blue1Brown), 
[[2]](https://www.youtube.com/watch?v=zjMuIxRvygQ&ab_channel=3Blue1Brown), 
It solves the problem that the Euler rotation can only rotate in the X, Y, Z axis, and the direction of rotation in this code is using right-hand rule.
## Fitting Code
### [CircleFit.m](https://github.com/BoHao-Peng/Matlab/blob/main/Fitting%20Code/CircleFit.m)
This code is written with reference to [this](https://www.sciencedirect.com/science/article/pii/0734189X89900881), 
Given the coordinates of a set of points, this function will return the cecnter coordinates and aradius of the circle
### [PlaneFit.m](https://github.com/BoHao-Peng/Matlab/blob/main/Fitting%20Code/PlaneFit.m)
This is the code for the plane fit, this function has problems when the plane is almost perpendicular to the Z axis.
## Hardware Control Object
### [CONEXController.m](https://github.com/BoHao-Peng/Matlab/blob/main/Hardware%20Control%20Object/CONEXController.m)
This is the object used to control the Newport Rotation Stage ([CONEX-URS50BCC](https://www.newport.com/p/CONEX-URS50BCC)).
### [PointGrey.m](https://github.com/BoHao-Peng/Matlab/blob/main/Hardware%20Control%20Object/PointGrey.m)
This is the object used to control PointGrey Camera, this code needs "Image Acqusition Toolbox" and "Point Grey P
### [SMC100CC_Controller.m](https://github.com/BoHao-Peng/Matlab/blob/main/Hardware%20Control%20Object/SMC100CCController.m)
This is the object used to control the Newport Linear Stage ([SMC100CC](https://www.newport.com/p/SMC100CC) with [MFA-CC](https://www.newport.com/p/MFA-CC)).
## Optics
### [SeidelSampling.m](https://github.com/BoHao-Peng/Matlab/blob/main/Optics/SeidelSampling.m)
It's the function to create seidel aberration.
### [ZernikeSampling](https://github.com/BoHao-Peng/Matlab/blob/main/Optics/ZernikeSampling.m)
It's the function to create zernike aberration (fringe zernike).
## Others
### [Graphical_Mask](https://github.com/BoHao-Peng/Matlab/blob/main/Others/Graphical_Mask.m)
This is a GUI example for creating a draggable circular mask.
### [SaveData](https://github.com/BoHao-Peng/Matlab/blob/main/Others/SaveData.m)
This is a function used to save data with the variable name you want, and this function is written for data storage for parallel operations.
### [polarPcolor](https://github.com/BoHao-Peng/Matlab/blob/main/Others/polarPcolor.m)
This code is modified from [this](https://www.mathworks.com/matlabcentral/fileexchange/49040-pcolor-in-polar-coordinates),
the purpose of this function is to plot the data in ploar coordinates.
