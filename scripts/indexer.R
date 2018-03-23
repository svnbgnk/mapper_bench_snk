#
# COLUMNS contains strings in the form <prefix>_<subexp>[_bw]
#
# Rabema columns (e.g. Ra_all, Rrx_best):
#   Rr*_* ... Rabema relative numbers
#   Ra*_* ... Rabema absolute numbers
#   R?x_* ... add extra column with values for each error
#
#   R*_all ....... all matches
#   R*_best ...... all best matches
#   R*_any-best .. any best match
#
# Performance columns:
#   P_time ......... runtime
#   P_memory ....... memory consumption
#
# The optional _bw suffix disables colored cells
#
source(file="scripts/common.R")

prefix_headers = ""
prefix_units = "\\footnotesize"
prefix_indexers = ""
show_units = TRUE

SHOW_MODE = FALSE
SUBCOLUMNS = 3
DIGITS = 1

write_table <- function(tex_out)
{
    rnames = c()
    space = ""
    space2 = ""
    separator = ""

    M = c()
    for (mi in seq(length(MODES)))
    {
        mode = MODES[mi]        
        INDEXERS = (MODE2INDEXERS[[mode]])
        for (i in seq(length(INDEXERS)))
        {
            indexer = INDEXERS[i]
            colheaders = ""
            colheaders_units = ""
            align = ifelse(SHOW_MODE, yes="ll", no="l")
            line = c()
            
            for (io in seq(length(DATASET)))
            {
                dataset=DATASET[io]
                
                for (j in seq(length(COLUMNS)))
                {
                    col = COLUMNS[j]
                    colname = sanitize(col)
                    unit = ""
                    subexp = sub("^P_", "", col)

                    RESOURCE_FILE_FM= paste(RESULT_DIR, paste(dataset, indexer, "index.res", sep='.'), sep='/')
                    RESOURCE_FILE_IBF = paste(RESULT_DIR, paste(dataset, indexer, "ibf.res", sep='.'), sep='/')

                        
                    resFile = c()
                    resFileTS = c()
                    x = "--\\ \\ "
                    date = ""
                        
                    if (subexp == "bin_size")
                    {
                        colname = "Bins"
                        x = paste(INDEXER_BIN_SIZE[indexer], "\\ \\ ", sep='')
                    }
                    if (subexp == "build_time" || subexp == "update_time" )
                    {
                        colname = "Build Runtime"
                        if (subexp == "update_time")
                        {
                            RESOURCE_FILE_FM= paste(RESULT_DIR, paste(dataset, indexer, "index.up.res", sep='.'), sep='/')
                            RESOURCE_FILE_IBF = paste(RESULT_DIR, paste(dataset, indexer, "ibf.up.res", sep='.'), sep='/')
                            colname = "Update Runtime"
                        }
                        unit = "[min:s]"
                        field = "wc_time"
                        if ((R = load_file(RESOURCE_FILE_FM))$ok)
                        {
                            fm_time=sum(R$tsv[field])
                        } 
                        else
                        {
                            fm_time=0
                            print(paste("skip",RESOURCE_FILE_FM))
                        }
                        if ((R = load_file(RESOURCE_FILE_IBF))$ok)
                        {
                            ibf_time=sum(R$tsv[field])
                        } 
                        else
                        {
                            ibf_time=0
                        }
                        if (fm_time > 0 && ibf_time > 0)
                        {
                            x = paste("\\celltrio{", secsToTime(fm_time+ibf_time),"}{", secsToTime(fm_time), "}{", secsToTime(ibf_time), "}", "\\ \\", sep='')
                        } 
                        else if(fm_time > 0)
                        {
                            x = paste(secsToMinSec(fm_time), "\\ \\ ", sep='')
                        }
                    }

                    if (subexp == "memory" )
                    {
                        colname = "Memory"
                        unit = "[GB]"
                        field = "rss_mem_peak"
                        if ((R = load_file(RESOURCE_FILE_FM))$ok)
                        {
                            fm_maxMem=max(R$tsv[field])
                        } 
                        else
                        {
                            fm_maxMem=0
                            print(paste("skip",RESOURCE_FILE_FM))
                        }
                        if ((R = load_file(RESOURCE_FILE_IBF))$ok)
                        {
                            ibf_maxMem=max(R$tsv[field])
                        } 
                        else
                        {
                            ibf_maxMem=0
                        }
                        if (fm_maxMem > 0 && ibf_maxMem > 0)
                        {
                            all_maxMem = max(fm_maxMem, ibf_maxMem)
                            f_all_maxMem=format(round(all_maxMem/1024.0^2,2), nsmall=2)
                            f_fm_maxMem=format(round(fm_maxMem/1024.0^2,2), nsmall=2)
                            f_ibf_maxMem=format(round(ibf_maxMem/1024.0^2,2), nsmall=2)
                            x = paste("\\celltrio{", f_all_maxMem,"}{", f_fm_maxMem, "}{", f_ibf_maxMem, "}", sep='')
                        } 
                        else if(fm_maxMem > 0)
                        {
                            x=format(round(fm_maxMem/1024.0^2,2), nsmall=2)
                        }
                    }
                    align = paste(align, "r", sep='')
                    colheaders = paste(colheaders, "&\\multicolumn{1}{r}{", prefix_headers, colname, "}")
                    colheaders_units = paste(colheaders_units, "&\\multicolumn{1}{r}{", prefix_units, unit, "}")
                    line = c(line, x)
                }
            }
            M = rbind(M, c(paste(prefix_indexers, INDEXER_LABEL[indexer], space2), line))
        }
        # vertical mode description at the left of the table
        if (mi == length(MODES) || MODE_LABEL[mode] != MODE_LABEL[MODES[mi + 1]])
        {
            if (length(M) > 0 && length(rnames) < nrow(M))
            {
                rnames = c(rnames,paste(separator,"\\multirow{",nrow(M)-length(rnames),"}{*}{\\begin{sideways}",MODE_LABEL[mode],"\\quad\\ \\end{sideways}}",sep=''))
                separator = "\\midrule"
                while (length(rnames) < nrow(M))
                {
                    space = paste(space, "")
                    rnames = c(rnames,space)
                }
            }
            space2 = paste(space2, "")
        }
    }

    if (!SHOW_MODE)
    {
        rnames = M[,1]
        M = M[,2:ncol(M)]
    }
    rownames(M) = rnames
    
    extraTab = ifelse(SHOW_MODE, yes="&", no="")    
    midrules = ""
    superheader = ""
    superheader_extra = ""

    if (length(DATASET) > 1)
    {
        i = ifelse(SHOW_MODE, yes=2, no=1)
        for (text in DATASET)
        {
            superheader = paste(superheader, "&\\multicolumn{", length(COLUMNS), "}{c}{", prefix_headers, sanitize(dataset_label(text)), "}")
            midrules = paste(midrules, "\\cmidrule(lr){", i + 1, "-", i + length(COLUMNS), "}", sep="")
            i = i + length(COLUMNS)
        }
        superheader = paste(superheader, "\\\\\n  ")
        
        if (length(DATASET_LABEL) > 1)
        {
            superheader_extra = extraTab
            for (text in DATASET_LABEL)
                superheader_extra = paste(superheader_extra, "&\\multicolumn{", length(COLUMNS), "}{c}{", prefix_headers, sanitize(text), "}", sep="")
            superheader_extra = paste(superheader_extra, "\\\\\n  ")
            superheader = paste(extraTab, "\\multirow{2}{*}{}", superheader)
        } else
            superheader = paste(extraTab, "{}", superheader)
    }
    
    if (show_units)
    {
#        colheaders_units = paste(extraTab, "Mapper", colheaders_units)
        colheaders = paste(extraTab, colheaders)
    } #else
#        colheaders = paste(extraTab, "Mapper", colheaders)
    
    cmd = c(
        paste(
            "\\toprule\n  ",
            superheader,
            superheader_extra,
            midrules, " \n  ",
            colheaders, " \\\\\n  ",
            ifelse(show_units, yes = paste(colheaders_units, "\\\\\n"), no = ""),
            sep=''),
        '\\midrule\n',
        '\\bottomrule\n')

    U <- xtable(M, align=align)
    print(
        U,
        file=tex_out,
        floating=FALSE,
        include.rownames=TRUE,
        include.colnames=FALSE,
        sanitize.text.function=identity,
        sanitize.colnames.function=identity,
        sanitize.rownames.function=sanitize,
        hline.after=NULL,
        only.contents=FALSE,
        append=FALSE,
        add.to.row=list(pos=list(-1,0, nrow(M)), command=cmd)
    )
}