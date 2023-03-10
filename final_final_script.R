library(readxl)
library(knitr)
library(dplyr)
library(aod)
library(ggplot2)
library(car)
library(sqldf)
library(pscl)
require(MASS)
require(boot)
require(foreign)
library(gtsummary)

# OHSA Sunbelt
ggplot(sb, aes(x=Median_HHI_20, y=Point_Count_1)) +
  geom_point()

sb.all.ohsa <- glm.nb(Point_Count_1 ~ Car_Per + NW_DIFF2 + Median_HHI_20, data=sb)
summary(sb.nb.ohsa)

# Normal Sunbelt
ggplot(sb, aes(x=Median_HHI_20, y=Point_Count)) +
  geom_point()

sb.all.nor <- glm.nb(Point_Count ~ Car_Per + NW_DIFF2 + Median_HHI_20, data=sb)
summary(sb.nb.nor)

# Combo Table
sb.all.ohsa.tbl <- add_vif(tbl_regression(sb.all.ohsa, exponentiate=TRUE))
sb.all.nor.tbl <- add_vif(tbl_regression(sb.all.nor, exponentiate=TRUE))

sb.all.tbl <- tbl_merge(tbls=list(sb.all.ohsa.tbl, sb.all.nor.tbl), tab_spanner = c("Hot Spots", "All Crashes"))
sb.all.tbl

# Non-Sunbelt OHSA
ggplot(n.sb, aes(x=Median_HHI_20, y=Point_Count_1)) +
  geom_point()

n.sb.all.ohsa <- glm.nb(Point_Count_1 ~ Car_Per + NW_DIFF2 + Median_HHI_20, data=n.sb)
summary(n.sb.all.ohsa)
# Non-Sunbelt has a slight relationship to these 3 variables, but the vast majority of tracts are 0.

# Non-Sunbelt Normal
ggplot(n.sb, aes(x=Median_HHI_20, y=Point_Count)) +
  geom_point()

n.sb.all.nor <- glm.nb(Point_Count ~ Car_Per + NW_DIFF2 + Median_HHI_20, data=n.sb)
summary(n.sb.all.nor)

# Combo Table
n.sb.all.ohsa.tbl <- add_vif(tbl_regression(n.sb.all.ohsa, exponentiate=TRUE))
n.sb.all.nor.tbl <- add_vif(tbl_regression(n.sb.all.nor, exponentiate=TRUE))

n.sb.all.tbl <- tbl_merge(tbls=list(n.sb.all.ohsa.tbl, n.sb.all.nor.tbl), tab_spanner = c("Hot Spots", "All Crashes"))
n.sb.all.tbl
# Non-Sunbelt Normal has no real linear relationship to Car_Per or NW_DIFF2


#### NOT REGRESSION ####
# Only uses points in either a hot or cold fatality cluster at p <= 0.05

# Comparing the hot/cold spots in cities that have them show this mismatch
# Orlando and Jacksonville only have hot spots, Seattle only has cold spots
ggplot(ohsa_binary_groups$`1`, aes(x = DIST_KM)) +
  geom_histogram(fill = "white", colour = "black") +
  facet_grid(HOT ~ .)

ggplot(ohsa_binary_groups$`0`, aes(x = DIST_KM)) +
  geom_histogram(fill = "white", colour = "black") +
  facet_grid(HOT ~ .)

wilcox.test(ohsa_dist_groups$ATL$DIST_KM ~ ohsa_dist_groups$ATL$HOT, paired=FALSE, alternative="less")
wilcox.test(ohsa_dist_groups$POR$DIST_KM ~ ohsa_dist_groups$POR$HOT, paired=FALSE, alternative="less")

ggplot(todo, aes(x = NW_DIFF2)) + 
  geom_histogram(fill = "white", colour = "black", binwidth = .05) + 
  facet_grid(Sunbelt ~ .)

# The average tract has around the same number of crashes (9 vs. 10), but Sunbelt has 10x more OHSA

## Final Thoughts
# It definitely seems that NW_DIFF, Car_Per, and Distance are factors for the Sunbelt.
# It seems like the Non-Sunbelt have these patterns, but have slower roads and less racialized minorities
# to discriminate against

sb.crashes <- sqldf("SELECT * FROM all_crashes WHERE Sunbelt = 1")
nsb.crashes <- sqldf("SELECT * FROM all_crashes WHERE Sunbelt = 0")

sb.ohsa.crashes <- sqldf('SELECT * FROM all_crashes_OHSA_distance WHERE SUNBELT = 1')
nsb.ohsa.crashes <- sqldf('SELECT * FROM all_crashes_OHSA_distance WHERE SUNBELT = 0')


ggplot(cluster_tract_centroids, aes(Poverty_Rate_20, NEAR_DIST)) +
  geom_point() +
  facet_grid(Metro ~ .)
     