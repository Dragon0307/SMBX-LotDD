local warpTransition = require("warpTransition")
warpTransition.crossSectionTransition = warpTransition.TRANSITION_IRIS_OUT

lhp.setHP(752, 30) -- Chompy, Phase 1
lhp.setHP(754, 30) -- Chompy, Phase 2

stats.xpDrop(754, 6)