# install.packages("xtable",  dep = TRUE, repos="http://cran.r-project.org")
# install.packages("scales",  dep = TRUE, repos="http://cran.r-project.org")
# install.packages("sitools", dep = TRUE, repos="http://cran.r-project.org")
library("xtable")
library("scales")
library("sitools")
#library("ggthemes")

# PDF
SCALE=0.4
PDF_WIDTH=15
PDF_HEIGHT=7
FONT_SIZE=10
POINT_SIZE=2
FONT_FAMILY='Cambria'

# Colors
rgb255 <- function(r,g,b,alpha) rgb(colorRamp(c("white",rgb(r,g,b,maxColorValue=255)), space = "rgb")(alpha/255.0),maxColorValue=255)
mycolors <- function(alpha)
{
    c(
        rgb255(25,90,168,alpha),    # blue
        rgb255(1,2,2,alpha),        # black
        rgb255(236,46,47,alpha),    # red
        rgb255(179,56,147,alpha),   # pink
        rgb255(13,140,73,alpha),    # green
        rgb255(243,125,38,alpha),   # orange
        rgb255(161,29,32,alpha),    # zinoba
        rgb255(101,44,144,alpha)    # purple
    )
}
MYCOLORS <- rbind(mycolors(255),mycolors(160),mycolors(85))

COLORS    = MYCOLORS[2,]
COLS      = c(COLORS[3], COLORS[6], COLORS[5]); # choose red, orange, green
PALETTE   = colorRamp(COLS, space = "rgb")

# Labels
#GENOTYPING_OFFICIAL = c(snp='SNVs',indel='INDELs')
#ACCURACY_OFFICIAL = c(sens='Sensitivity', spec='Specificity')

MODE_LABEL = c(default="default",rabema="all-best",build="build")
RABEMA_LABEL = c('all-best'='Co-opt.',all='Subopt.')

MAPPERS_LABEL = c(
    yara_rabema="Yara [s=0]",
    didabwa_rabema="DIDA-BWA",
    dyara_rabema_taxo_1024="Dream Yara [s=0]",
    dyara_rabema_taxo_256="Dream Yara [s=0]",
    dyara_rabema_taxo_64="Dream Yara [s=0]",
    distyara_rabema_taxo_1024="Distr. Yara [s=0]",
    distyara_rabema_taxo_256="Distr. Yara [s=0]",
    distyara_rabema_taxo_64="Distr. Yara [s=0]",
    bowtie2_rabema="Bowtie 2",
    bwa_rabema="BWA-MEM",
    gem_rabema="GEM"
)
INDEXER_LABEL = c(
    yara="Yara",
    didabwa="DIDA-BWA [1024]",
    dyara_taxo_1024="Dream Yara 1024",
    dyara_taxo_256 ="Dream Yara 256",
    dyara_taxo_64  ="Dream Yara 64",
    distyara_taxo_1024="Distr. Yara 1024",
    distyara_taxo_256 ="Distr. Yara 256",
    distyara_taxo_64  ="Distr. Yara 64",
    bowtie2="Bowtie 2",
    bwa="BWA-MEM",
    gem="GEM"
)

#Create a custom color scale
#MAPPERS_COLORS <- tableau_color_pal(palette="tableau20")(length(MAPPERS_LABEL))
MAPPERS_COLORS <- c("#FFBB78", "#FF9896", "#FF7F0E", "#D62728", "#9467BD", "#1F77B4", "#2CA02C", "#2CA02C", "#98DF8A", "#C49C94", "#8C564B")
INDEXERS_COLORS <- c("#FFBB78", "#FF9896", "#FF7F0E", "#D62728", "#9467BD", "#1F77B4", "#2CA02C", "#2CA02C", "#98DF8A", "#C49C94", "#8C564B")
names(MAPPERS_COLORS) <- names(MAPPERS_LABEL)
names(INDEXERS_COLORS) <- names(INDEXER_LABEL)

# ------

scientific_10 <- function(x)
{
    parse(text=gsub("e", " %*% 10^", scientific_format()(x)))
}

dataset_label <- function(dataset)
{
    return(dataset)
}

colorize <- function(value, text = "", enable=TRUE) {
    if (!is.na(value) && value >= 0 && value <= 1)
    {
        x = value**4
        col = PALETTE(x)
    }
    else
    {
        # mark strange values 
        col = c(0,0,255)
    }
    val = format(value * 100,nsmall=DIGITS,digits=1)
    # format sometimes produces spaces
    val = gsub(" ", "", val, fixed = TRUE)
    
    # left-pad invisible zeroes
    y = ""
    while (nchar(val) + nchar(y) < 4 + DIGITS)
        y = paste(y, "0", sep="")
    val = paste("\\phantom{", y, "}", val, sep="")
    
    if (text == "")
        text = val
    ifelse(enable, yes=paste("\\cellcolor[rgb]{", col[1]/255.0, ",", col[2]/255.0, ",", col[3]/255.0, "}", text, sep=""), no=text)
}

mark <- function(text)
{
    return(paste("\\cellcolor[rgb]{0,0,1}",text))
}

secsToTime <- function(secs)
{
    if (is.na(secs))
        return("--")
    
    ifelse (secs<3600,yes=sprintf("%d:%02d",floor(secs/60),floor(secs)%%60),no=sprintf("%01d:%02d:%02d",floor(secs/3600),(floor(secs/60))%%60,floor(secs)%%60))
}

secsToMinSec <- function(secs)
{
    if (is.na(secs))
        return("--")
    
    x = sprintf("%d:%02d",(floor(secs/60)),floor(secs)%%60)
    y = ""
    while (nchar(x) + nchar(y) < 7)
        y = paste(y, "0", sep="")
    paste("\\phantom{", y, "}", x, sep="")
}

sanitize <- function(str)
{
    result <- str
    result <- gsub("&", "\\&", result, fixed = TRUE)
    result <- gsub("_", "\\_", result, fixed = TRUE)
    result
}

checkNA <- function(y)
{
    any(is.na(y))
}

load_file <- function(filename)
{
    if (file.exists(filename))
    {
        # try the main resource file first
        print(paste("read",filename))
        tsvFile = try(read.delim(filename, header=TRUE))
        if (inherits(tsvFile,"try-error"))
        {
            print(paste("EMPTY FILE:", filename))
            return(list(ok=FALSE))
        }
        if (nrow(tsvFile) < 1)
        {
            print(paste("BAD FORMAT:", filename))
            return(list(ok=FALSE))
        }
        if (any(apply(tsvFile, 1, checkNA)))
        {
            print(paste("BAD FORMAT:", filename))
            return(list(ok=FALSE))
        }
        return(list(ok=TRUE,tsv=tsvFile))
    } else
        return(list(ok=FALSE))
}

load_rabema <- function(filename)
{    
    if (file.exists(filename))
    {
        print(paste("read",filename))
        tsvFile <- read.delim(filename, comment.char="#", header=FALSE, col.names=c("error_rate","num_max","num_found","percent_found","norm_max","norm_found","percent_norm_found"))
        return(list(ok=TRUE,tsv=tsvFile))
    } else
        return(list(ok=FALSE))
}
