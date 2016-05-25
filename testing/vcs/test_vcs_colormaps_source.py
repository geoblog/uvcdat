import argparse, os, sys, cdms2, vcs, testing.regression as regression

parser = argparse.ArgumentParser()
parser.add_argument("-g",dest="gm",default="boxfill",choices = ["boxfill","isofill","meshfill","isoline","vector","1d"])
parser.add_argument("-s",dest="src",default="vcs",choices=["vcs","canvas","gm"])
parser.add_argument("-b",dest="baseline")
args = parser.parse_args()

x = regression.init()

exec("gm = x.create%s()" % args.gm)

if args.src == "vcs":
  vcs._colorMap = "blue_to_grn"
elif args.src == "canvas":
  ## Still setting vcs to make sure it is not used
  vcs._colorMap = "blue_to_grn"
  x.setcolormap("blue_to_grey")
else:
  ## Still setting vcs and canvas to make sure it is not used
  vcs._colorMap = "blue_to_grn"
  x.setcolormap("blue_to_grey")
  gm.colormap = "blue_to_orange"

if args.gm != "meshfill":
  f=cdms2.open(os.path.join(vcs.sample_data,"clt.nc"))
  if args.gm == "vector":
    u = f("u")
    v = f("v")
  else:
    s=f("clt",slice(0,1))
else:
  f=cdms2.open(os.path.join(vcs.sample_data,'sampleCurveGrid4.nc'))
  s=f("sample")
if args.gm == "vector":
  x.plot(u,v,gm,bg=True)
else:
  x.plot(s,gm,bg=True)

fnm = "test_vcs_colormaps_source_%s_%s.png" % (args.gm,args.src)
x.png(fnm)
baselineImage = args.baseline
ret = regression.run(x, fnm, baselineImage)