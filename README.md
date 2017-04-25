# README #

Demo code associated with developing a ptychography
and phase retrieval algorithm for a senior design project

## Getting Started ##

```
#!matlab

mock
object = reconstruct(filename,5);
```

Will generate mock image data and save it to a file,
then reconstruct using five iterations

Plotting is on by default, and will severely slow down the
reconstruction.  This can be disabled by changing `plotprogress` to
`false` on line 17 of reconstruct.m.  

Computing and plotting the reconstructed object at every stage also
slows things down, and can be disabled by setting `plotobject` to
`false` on line 18 of reconstruct.m.  

## Structure of the algorithm ##

The meat of the ptychography algorithm starts on line 130 of
reconstruct.m.  Everything before that is just importing data and
calculating parameters.  

At each step, a region of the reconstructed object's spectrum
(`objectFT`) is extracted (line 163), and the size constraint associated
with the objective's NA is applied (line 164).  After transforming back
to the spatial domain (line 167), the intensity is replaced with the
measured intensity from the corresponding sub-image, while keeping the
phase (lines 169--170).  The piece is then transformed back (line 173),
and the sub region of the object's spectrum is replaced with the updated
data (lines 175--176).  

The reconstructed object will be displayed after the algorithm is done.
The original complex object can be viewed with:

```
#!matlab

subplot(121); imagesc(abs(I)); title('Original Magnitude'); axis image;
subplot(122); imagesc(angle(I)); title('Original Phase'); axis image;
colormap gray;
```
