# weather from cdo for palm springs 2017

library(ggplot2)
library(dplyr)
library(scales)
library(lubridate)
library(cowplot)
library(ggrepel)

# make functions for c3gp and c4gp

# make function to calc gp C3
c3gp <- function(x) {
  GP <- 2.71828 ^ (-0.5 * ((x - 20) / 5.5) ^ 2)
  return(GP)
}

# function to calculate gp C4
# note, use 8.5 for my way,  for Stowell use 7

c4gp <- function(x) {
  GP <- ifelse(x >= 31, 1, 2.71828 ^ (-0.5 * ((x - 31) / 7) ^ 2))
  return(GP)
}

palm <- read.csv("~/Documents/Rs/98-17_palm_springs.csv",
                header = TRUE)

levels(palm$NAME)

#palm <- subset(all, NAME == "PALM SPRINGS REGIONAL AIRPORT, CA US")
palm$temperature <- (palm$TMAX + palm$TMIN) / 2

#set for sep 5 2004 as 30
palm$temperature <- ifelse(is.na(palm$temperature), 30, palm$temperature)



hist(palm$temperature)

palm$date <- ymd(as.character(palm$DATE))

palm$C3 <- c3gp(palm$temperature)
palm$C4 <- c4gp(palm$temperature)

palm$month <- month(palm$date)
palm$year <- year(palm$date)
palm$yday <- yday(palm$date)
palm$day <- day(palm$date)

forPlot <- subset(palm, month >= 8)

forPlot$trickyYear <- 2017
forPlot$trickyDate <- ymd(paste(forPlot$trickyYear, forPlot$month, forPlot$day))

forPlot$diffGP <- forPlot$C3 - forPlot$C4

forPlot$diffSum <- ave(forPlot$diffGP, forPlot$year, FUN = cumsum, na.rm = TRUE)

# make a plot from 1 Aug to 30 Nov to find inflection
p <- ggplot(data = forPlot, aes(x = trickyDate, 
                            y = diffSum))

p + geom_line(na.rm = TRUE) + background_grid(major = "xy") +
  labs(title = "Palm Springs Regional Airport, 1998 to 2017", x = "Date", 
       y = (expression(paste('cumulative sum of (', C[3], ' GP - ', C[4], ' GP)'))),
       caption = "data from https://www.ncdc.noaa.gov/cdo-web/",
       subtitle = "data for 2017 up to Oct 25") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  facet_wrap(~year) 

# min by year

yearMin <- forPlot %>% 
  arrange(diffSum) %>% 
  distinct(year, .keep_all = TRUE)

yearMin$chardate <- as.character(yearMin$date)

p <- ggplot(data = yearMin, aes(x = year, y = trickyDate, label = chardate))
p + geom_point(shape = 1, color = "brown") +
  background_grid(major = "xy") +
 # geom_smooth(se = FALSE, method = "lm") +
  scale_x_continuous(breaks = seq(1998, 2017, 1)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(x = "Year",
       y = "Date of inflection point",
       title = "Palm Springs Regional Airport, 1998 to 2017",
       subtitle = "data for 2017 up to Oct 25",
       caption = "data from https://www.ncdc.noaa.gov/cdo-web/") +
  geom_text_repel()

plot(density(yearMin$yday))

summary(yearMin)

