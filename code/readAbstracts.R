library(tidyverse)

bib <- read.table("inputs/MyBibliography.bib", sep = "\n", quote = "") %>%
  filter(str_detect(V1, "^abstract") | str_detect(V1, "^title")) %>%
  separate(V1, c("Type","Text"), sep = " = ") %>%
  mutate(Number = floor((row_number()+1)/2)) %>%
  mutate(Text = str_replace_all(Text,"\\{",""),
         Text = str_replace_all(Text,"\\}",""),
         Text = str_replace_all(Text, ",$",""))

# Shows which abstracts are missing
# bib %>% filter((1:nrow(.) %%2)==1) %>% 
#   filter(Type == "title") %>% 
#   slice(1) %>% .$Text 

bib <- bib %>%
  spread(key = Type, value = Text) %>%
  select(Number, title, abstract)

texlist <- NULL
for (i in 1:nrow(bib)) {
  title <- paste0("\\section{", bib$title[i],"}")
  abstract <- bib$abstract[i]
  texlist <- paste0(texlist, title, " \n ", abstract, "\n \n")
}


# Copy files to clipboard -------------------------------------------------

clip <- pipe("pbcopy", "w")                       
write.table(x = texlist, file=clip, sep = '\t', row.names = FALSE, quote = FALSE)                               
close(clip)


# Insert results in tex file ----------------------------------------------

dir.create("outputs", showWarnings = FALSE)

template <- read_file("inputs/template.tex")

n1 <- str_length("\\end{document}") 
template <- str_sub(template, 1, str_length(template) - n1)

texlist <- str_sub(texlist, 2, nchar(texlist))

output <- paste0(template, texlist, "\\end{document}", collapse = "")

write(x = output, file = "outputs/abstracts.tex")


