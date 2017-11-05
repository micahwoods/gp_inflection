# palm springs from 1906, how is it

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

palm <- read.csv("~/Documents/Rs/1906_kara_palm_springs.csv",
                 header = TRUE)

levels(palm$NAME)

#palm <- subset(all, NAME == "PALM SPRINGS REGIONAL AIRPORT, CA US")
palm$temperature <- (palm$TMAX + palm$TMIN) / 2

#set for sep 5 2004 as 30
# palm$temperature <- ifelse(is.na(palm$temperature), 30, palm$temperature)



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

forPlot$diffSum <- ave(forPlot$diffGP, forPlot$year, FUN = cumsum, na.rm = FALSE)
forPlot$indicatorSum <- ave(forPlot$temperature, forPlot$year, FUN = sum, na.rm = FALSE)
forPlot$indicatorLength <- ave(forPlot$temperature, forPlot$year, FUN = length)

cleaned <- subset(forPlot, indicatorSum > 0 & indicatorLength == 153)

p <- ggplot(data = forPlot, aes(x = date, y = temperature))
p + geom_point(shape = 1, alpha = 0.25)
# make a plot from 1 Aug to 30 Nov to find inflection
p <- ggplot(data = cleaned, aes(x = trickyDate, 
                                y = diffSum))

p + geom_line(na.rm = TRUE) + background_grid(major = "xy") +
  labs(title = "Palm Springs Regional Airport, 1998 to 2017", x = "Date", 
       y = (expression(paste('cumulative sum of (', C[3], ' GP - ', C[4], ' GP)'))),
       caption = "data from https://www.ncdc.noaa.gov/cdo-web/",
       subtitle = "data for 2017 up to Oct 25") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  facet_wrap(~year) 

# min by year
yearMin <- cleaned %>% 
  arrange(diffSum) %>% 
  distinct(year, .keep_all = TRUE)

yearMin$chardate <- as.character(yearMin$date)

summary(yearMin)

p <- ggplot(data = yearMin, aes(x = year, y = trickyDate, label = chardate))
p + 
  background_grid(major = "xy") +
  geom_hline(yintercept = mean(yearMin$trickyDate),
             linetype = "dashed", colour = "mediumseagreen") +
  geom_point(shape = 1, color = "brown") +
  scale_x_continuous(breaks = seq(1920, 2015, 5)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(x = "Year",
       y = "Date of inflection point",
       title = "Palm Springs, California, 1922 to 2013",
       subtitle = "years with missing data omitted",
       caption = "data from https://www.ncdc.noaa.gov/cdo-web/") +
 geom_text_repel() +
  annotate("text", x = 1992, y = ymd(20171010), hjust = 0,
           colour = "mediumseagreen", label = "average date: October 8")
