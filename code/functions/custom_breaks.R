#################################################################################################################
# custom_breaks.R
#
# Function to set custom axis breaks.
#
#################################################################################################################

custom_breaks <- function(x) {
  unlist(case_when(max(x) > 10     & max(x) <= 20    ~ list(seq(0, 20, by = 5)),
                   max(x) > 20     & max(x) <= 40    ~ list(seq(0, 40, by = 10)),
                   max(x) > 40     & max(x) <= 60    ~ list(seq(0, 60, by = 10)),
                   max(x) > 60     & max(x) <= 80    ~ list(seq(0, 80, by = 20)),
                   max(x) > 80     & max(x) <= 100   ~ list(seq(0, 100, by = 25)),
                   max(x) > 100    & max(x) <= 200   ~ list(seq(0, 200, by = 50)),
                   max(x) > 200    & max(x) <= 600   ~ list(seq(0, 600, by = 100)),
                   max(x) > 600    & max(x) <= 800   ~ list(seq(0, 800, by = 200)),
                   max(x) > 800    & max(x) <= 1000  ~ list(seq(0, 1000, by = 200)),
                   max(x) > 1000   & max(x) <= 1200  ~ list(seq(0, 1200, by = 300)),
                   max(x) > 1200   & max(x) <= 2000  ~ list(seq(0, 2000, by = 500)),
                   max(x) > 2000   & max(x) <= 2500  ~ list(seq(0, 2500, by = 500)),
                   max(x) > 2500   & max(x) <= 5000  ~ list(seq(0, 5000, by = 1000)),
                   max(x) > 5000   & max(x) <= 8000  ~ list(seq(0, 8000, by = 2000)),
                   max(x) > 8000   & max(x) <= 10000 ~ list(seq(0, 10000, by = 2000)),
                   max(x) > 10000  & max(x) <= 15000 ~ list(seq(0, 15000, by = 3000)),
                   max(x) > 15000  & max(x) <= 20000 ~ list(seq(0, 20000, by = 4000)),
                   max(x) > 20000  & max(x) <= 25000 ~ list(seq(0, 25000, by = 5000)),
                   max(x) > 25000  & max(x) <= 35000 ~ list(seq(0, 35000, by = 7000)),
                   max(x) > 35000  & max(x) <= 40000 ~ list(seq(0, 40000, by = 8000)),
                   max(x) > 40000  & max(x) <= 75000 ~ list(seq(0, 75000, by = 15000)),
                   max(x) > 75000                    ~ list(seq(0, 100000, by = 20000)),
                   TRUE                              ~ list(seq(0, 0, by = 0))))
}
