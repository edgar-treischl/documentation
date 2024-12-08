```r
library(text)
# Example text 
texts <- c("I feel not so great.")

# Transform the text to BERT word embeddings
wordembeddings <- textEmbed(texts = texts,
                            model = 'bert-base-uncased',
                            layers = 11:12,
                            aggregation_from_layers_to_tokens = "concatenate",
                            aggregation_from_tokens_to_texts = "mean"
)

wordembeddings
```
