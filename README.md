### What's this about

When is an optimum time to seed cool-season grass when overseeding into a warm-season turf? 

Jim Schmid asked about 2017 in this discussion: <https://twitter.com/paceturf/status/925856403213901824>. I thought it would be interesting to look at a time series for Palm Springs.

Take, for example, the daily summary data data, and pool the measurements for the different locations so that I get something without NAs. I got some time series but they all seem to include too many missing values. However, I think I can take the data and take an average of a few stations in Palm Springs to markedly reduce the NAs.

After doing that, I get 55 years from 1992 to 2016 without any missing temperature data. The files in the `r` folder show the calculations I made and the code to generate some charts.

### More info 

* the data are obtained from the *Daily Summary* set, and I searched for **Palm Springs** as a city, and downloaded all available temperature data, at the [Climate Data Online](https://www.ncdc.noaa.gov/cdo-web/search) search page. There is an [`rnoaa`](https://cran.r-project.org/web/packages/rnoaa/index.html) package on CRAN that could probably obtain these data too, but I still default to using the web-based search.
* [Another way to look at growth potential and overseeding](http://www.seminar.asianturfgrass.com/20140224_overseeding_growth_potential_charts.html)
* [Growth potential, inflection points, and an optimum date for overseeding](http://www.blog.asianturfgrass.com/2014/02/growth-potential-inflection-points-and-an-optimum-date-for-overseeding.html)
* [Motion chart: difference between warm and cool-season growth potential](http://climate.asianturfgrass.com/inflection)
* [One more look at accumulated difference in growth potential and overseeding](http://www.blog.asianturfgrass.com/2014/02/one-more-look-at-accumulated-difference-in-growth-potential-and-overseeding.html)