# palm springs from 1902 multiple stations, averaged so no missing data

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

cToF <- function(x) {
  fahrenheit <- x * (9/5) + 32
  return(fahrenheit)
}

palm1 <- read.csv("data/palm_springs_1902_1959.csv",
                 header = TRUE)

palm2 <- read.csv("data/palm_springs_1960_2017.csv",
                  header = TRUE)

d <- rbind.data.frame(palm1, palm2)

levels(d$NAME)

summary(d)

d <- subset(d, ELEVATION < 200)

d$date <- ymd(as.character(d$DATE))
d$month <- month(d$date)

forPlot <- subset(d, month >= 8 & month <= 11)

forPlot$temperature <- (forPlot$TMAX + forPlot$TMIN) / 2

d2 <- forPlot %>%
  group_by(date) %>%
  summarise(temperature = mean(temperature, na.rm = TRUE))

d2$C3 <- c3gp(d2$temperature)
d2$C4 <- c4gp(d2$temperature)

d2$month <- month(d2$date)
d2$year <- year(d2$date)
d2$yday <- yday(d2$date)
d2$day <- day(d2$date)

d2$trickyYear <- 2017
d2$trickyDate <- ymd(paste(d2$trickyYear, d2$month, d2$day))

d2$diffGP <- d2$C3 - d2$C4

d2$diffSum <- ave(d2$diffGP, d2$year, FUN = cumsum, na.rm = FALSE)
d2$indicatorSum <- ave(d2$temperature, d2$year, FUN = sum, na.rm = FALSE)
d2$indicatorLength <- ave(d2$temperature, d2$year, FUN = length)

cleaned <- subset(d2, indicatorSum > 0 & indicatorLength == 122)

# min by year
yearMin <- cleaned %>% 
  arrange(diffSum) %>% 
  distinct(year, .keep_all = TRUE)

yearMin$chardate <- as.character(yearMin$date)

summary(yearMin)

p <- ggplot(data = yearMin, aes(x = year, y = trickyDate, label = chardate))
ps <- p + background_grid(major = "xy") +
  geom_hline(yintercept = median(yearMin$trickyDate),
             linetype = "dashed", colour = "mediumseagreen") +
  geom_point(shape = 1, color = "brown") +
  scale_x_continuous(breaks = seq(1920, 2015, 5)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(x = "Year",
       y = "Date of inflection point",
       title = "Palm Springs, California, 1922 to 2016",
       subtitle = "years with missing data omitted",
       caption = "data from https://www.ncdc.noaa.gov/cdo-web/") +
  geom_text_repel() +
  annotate("text", x = 1992, y = median(yearMin$trickyDate) - ddays(2), hjust = 0,
           colour = "mediumseagreen", 
           label = paste("average date: October", day(median(yearMin$trickyDate))))

ps

save_plot("~/Desktop/palm_springs_inflection.png", ps, base_aspect_ratio = 1.78,
          base_height = 7)

# temperature
p <- ggplot(data = cleaned, aes(x = trickyDate, y = cToF(temperature), group = year))
p + background_grid(major = "xy") +
  geom_line(alpha = 0.2) +
  labs(x = "Date",
       y = "Average temperature in °F",
       title = "Palm Springs, California, 1922 to 2016",
       subtitle = "years with missing data omitted",
       caption = "data from https://www.ncdc.noaa.gov/cdo-web/")

# gp cool and gp warm
p <- ggplot(data = cleaned, aes(x = trickyDate, y = c4gp(temperature), group = year))
p + background_grid(major = "xy") +
  geom_line(colour = "#e41a1c", alpha = 0.2) +
  geom_line(aes(x = trickyDate, y = c3gp(temperature), group = year),
            colour = "#377eb8", alpha = 0.2)

average_gp <- cleaned %>%
group_by(trickyDate) %>%
  summarise(gp4_average = mean(c4gp(temperature)),
            gp3_average = mean(c3gp(temperature)))

p <- ggplot(data = cleaned, aes(x = trickyDate, y = c4gp(temperature), group = year))
p + background_grid(major = "xy") +
  geom_line(colour = "#e41a1c", alpha = 0.2) +
  geom_line(aes(x = trickyDate, y = c3gp(temperature), group = year),
            colour = "#377eb8", alpha = 0.2) 
