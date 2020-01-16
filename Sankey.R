#######################
# Sankeydiagram maken #
#######################

#################################################################
# Packages laden

library(networkD3)
library(tidyverse)

#################################################################
# Dataset laden

sank <- read.csv(file = "./data/Sankey.csv", sep=";", dec = ",")

#################################################################
# Data bewerken

# Dataframe met nodes (= codes van landgebruiksklassen en bijhorende labels)

cp1 <- sank %>% 
  unite("cp1", c("jaarS","from")) %>%
  distinct(cp1) %>% 
  rename("codetxt" = cp1)
cp2 <- sank %>% 
  unite("cp2", c("jaarT","to")) %>% 
  distinct(cp2) %>% 
  rename("codetxt" = cp2)

nodes <- cp1 %>%
  bind_rows(cp2) %>% 
  distinct(codetxt) %>% 
  rownames_to_column() %>%
  rename("code" = rowname) %>% 
  mutate(code = as.numeric(code) - 1)

# Dataframe met links (= source (van), target (naar) en value (oppervlakte))

links <- sank %>%
  unite("cp1", c("jaarS","from")) %>%
  unite("cp2", c("jaarT","to")) %>% 
  left_join(nodes, by = c("cp1" = "codetxt")) %>% 
  rename(source = code) %>% 
  left_join(nodes, by = c("cp2" = "codetxt")) %>% 
  rename(target = code) %>% 
  dplyr::select(c(source, target, value))

# Aaneen plakken nodes en links in een List object

data <- list(nodes = nodes, links = links)

# Groepen aanmaken voor kleuren in grafiek en labels

groups <- sank %>%
  unite("cp1", c("jaarS","from"), remove = FALSE) %>%
  unite("cp2", c("jaarT","to"), remove = FALSE) %>% 
  left_join(nodes, by = c("cp1" = "codetxt")) %>% 
  rename(source = code) %>% 
  left_join(nodes, by = c("cp2" = "codetxt")) %>% 
  rename(target = code) 

# Groepen toewijzen aan nodes en links

links <- links %>% 
  left_join(select(groups, labelS, source), by = "source") %>% 
  rename("group" = "labelS")

nodes <- nodes %>% 
  left_join(select(groups, cp1, labelS), by = c("codetxt" = "cp1")) %>%  
  left_join(select(groups, cp2, labelT), by = c("codetxt" = "cp2")) %>%
  distinct(code, .keep_all = TRUE) %>% 
  mutate(group = coalesce(labelS, labelT))

#################################################################
# Sankeydiagram maken

sankeyNetwork(Links = data$links, Nodes = data$nodes, Source = 'source',
              Target = 'target', Value = 'value', NodeID = 'codetxt',
              units = 'ha', colourScale = , fontSize = 12, nodeWidth = 25, nodePadding = 20)

# Poging om de kleuren aan te passen

d3.scaleOrdinal(["#7d3945", "#e0677b", "#244457"])

sankeyNetwork(Links = data$links, Nodes = data$nodes, Source = 'source',
              Target = 'target', Value = 'value', NodeID = 'codetxt',
              units = 'ha', colourScale = , fontSize = 12, nodeWidth = 25, nodePadding = 20)



