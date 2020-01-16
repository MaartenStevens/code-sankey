library(networkD3)
library(tidyverse)

sank <- read.csv("Sankey_test.csv", sep=";", dec = ",")

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

links <- sank %>%
  dplyr::select(-c(source, target, code, name)) %>% 
  unite("cp1", c("jaarS","from")) %>%
  unite("cp2", c("jaarT","to")) %>% 
  left_join(nodes, by = c("cp1" = "codetxt")) %>% 
  rename(source = code) %>% 
  left_join(nodes, by = c("cp2" = "codetxt")) %>% 
  rename(target = code) %>% 
  dplyr::select(c(source, target, value))

data <- list(nodes = nodes, links = links)

sankeyNetwork(Links = data$links, Nodes = data$nodes, Source = 'source',
              Target = 'target', Value = 'value', NodeID = 'name',
              units = 'TWh', fontSize = 12, nodeWidth = 30)

