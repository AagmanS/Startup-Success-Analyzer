library(tidyverse)
library(ggplot2)
library(GGally)
library(MVN)
library(factoextra)
library(dplyr)

startup_funding <- read.csv("startup_funding.csv")

colnames(startup_funding) <- c("Company", "Sector", "Funding", "Investor", "Year", "City")

startup_funding$Sector <- as.factor(startup_funding$Sector)

startup_funding <- na.omit(startup_funding)


set.seed(123)

startup_funding$Revenue <- startup_funding$Funding * runif(nrow(startup_funding), 0.5, 2)

startup_funding$Employee <- round(startup_funding$Funding / 1000000 * runif(nrow(startup_funding), 5, 20))

startup_funding$Marketing <- startup_funding$Funding * runif(nrow(startup_funding), 0.1, 0.3)

startup_funding$Operational_Years <- 2024 - startup_funding$Year


ggplot(startup_funding, aes(x = Sector, y = Funding)) +
  geom_boxplot(fill = "skyblue") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ggtitle("Funding Distribution Across Sectors")

ggplot(startup_funding, aes(x = Revenue)) +
  geom_histogram(bins = 30, fill = "orange") +
  ggtitle("Revenue Distribution")

num_data <- startup_funding %>%
  select(Funding, Revenue, Employee, Marketing, Operational_Years)

GGally::ggpairs(num_data)

---------------------------

mvn_res <- startup_funding %>%
  select(Funding, Revenue, Marketing)

mvn_dataRes <- mvn(data = mvn_res, mvn_test = "mardia")

print(mvn_dataRes$multivariate_normality)



pca_data <- scale(startup_funding %>%
                    select(Funding, Revenue, Employee, Marketing))

pca <- prcomp(pca_data, center = TRUE, scale. = TRUE)

summary(pca)

fviz_eig(pca)

pca$rotation

startup_funding$Company_Scale <- pca$x[,1]
startup_funding$Operational_Intensity <- pca$x[,2]

fviz_pca_biplot(pca, repel = TRUE)



anova_model <- aov(Company_Scale ~ Sector, data = startup_funding)

summary(anova_model)

TukeyHSD(anova_model)

ggplot(startup_funding, aes(x = Sector, y = Company_Scale)) +
  geom_boxplot(fill = "lightgreen") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


write.csv(startup_funding, "processed_startup_data.csv", row.names = FALSE)