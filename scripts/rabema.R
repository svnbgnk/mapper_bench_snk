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
prefix_mappers = ""
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
        MAPPERS=(MODE2MAPPERS[[mode]])
#        M = matrix(nrow=length(MAPPERS), ncol=length(COLUMNS)*length(DATASET), dimnames=list(MAPPERS,rep(COLUMNS,length(DATASET))))
        
        for (i in seq(length(MAPPERS)))
        {
            mapper = MAPPERS[i]
            colheaders = ""
            colheaders_units = ""
            align = ifelse(SHOW_MODE, yes="ll", no="l")
            line = c()
            
            for (io in seq(length(DATASET)))
            {
                dataset=DATASET[io]
                if (typeof(num_reads) == "list")
                    NUM_READS=num_reads[[ mode ]]
                else
                    NUM_READS=num_reads
                
                for (j in seq(length(COLUMNS)))
                {
                    col = COLUMNS[j]
                    colname = sanitize(col)
                    unit = ""

                    enableColors = !grepl("_bw$", col)
                    col = sub("_bw$", "", col)

                    if (grepl("^R[a|r]x?_", col))
                    {
                        # rabema results
                        absoluteNumbers = grepl("^Rax?_", col)
                        extraColumn = grepl("^R[a|r]x_", col)
                        subexp = sub("^R[a|r]x?_", "", col)
                        colname = paste(RABEMA_LABEL[[subexp]], "locations")
                        unit = ifelse(absoluteNumbers, yes="", no="[\\%]")
                        align = paste(align, ifelse(absoluteNumbers, yes="r", no="c"), sep='')
                        
                        # ABSim_10000.A_B_refseq_20170926.yara_default.5.all-best.rabema_report_tsv
                        # RABEMA_FILE = paste(RESULT_DIR, paste(dataset, mapper, GOLD, MAX_ERRORS, subexp, "rabema_report_tsv", sep='.'), sep='/')
                        RABEMA_FILE = paste(RESULT_DIR, paste(dataset, mapper, MAX_ERRORS, subexp, "rabema_report_tsv", sep='.'), sep='/')
                        
                        if (file.exists(RABEMA_FILE))
                        {
                            print(paste("read",RABEMA_FILE))
                            raw.data <- read.delim(RABEMA_FILE, comment.char="#", header=FALSE, col.names=c("error_rate","num_max","num_found","percent_found","norm_max","norm_found","percent_norm_found"))
                            sens_per_error <- raw.data$norm_found / raw.data$norm_max
                            x <- colorize(sum(raw.data$norm_found) / sum(raw.data$norm_max), ifelse(absoluteNumbers, yes=round(sum(raw.data$norm_found)), no=""), enableColors)
                            
                            if (extraColumn)
                            {
                                s = paste("{\\subcolbeg\\begin{tabular}{", paste(rep("r",SUBCOLUMNS), collapse=""), "}", sep="")
                                
                                for (k in seq(ceiling(MAX_ERRORS / SUBCOLUMNS)))
                                {
                                    for (l in seq(SUBCOLUMNS))
                                    {
                                        # output separate sensitivities for errors=0,..,5
                                        err = (k - 1) * SUBCOLUMNS + (l - 1)
                                        if (err > MAX_ERRORS)
                                            next
                                        
                                        if (l > 1)
                                            s = paste(s, "&")
                                        # from_err = (err - 1) * READ_LENGTHS[io] / 100.0;
                                        # to_err   =  err      * READ_LENGTHS[io] / 100.0;
                                        from_err = (err - 1) ;
                                        to_err   =  err      ;
                                        #if (err == MAX_ERRORS)
                                        #    to_err = from_err + 1
                                        X=subset(raw.data, from_err < error_rate & error_rate <= to_err)
                                        if (nrow(X) == 1 && X$norm_max != 0)
                                        {
                                            text = ifelse(absoluteNumbers, yes=round(X$norm_found), no="")
                                            s = paste(s, colorize(X$norm_found / X$norm_max, text, enableColors))
                                        }
                                        else
                                            s = paste(s, '--')
                                    }
                                    if (k == ceiling(MAX_ERRORS / SUBCOLUMNS))
                                        s = paste(s, "\\subcolvspace", sep="")
                                    s = paste(s, "\\\\", sep="")
                                }
                                s = paste(s, "\\end{tabular}\\subcolend}", sep="")
                                x = paste(x, s)
                            }


                            if(REPORT_ABSOLUTE)
                            {
                                line = c(line, x)
                                align = paste(align, "l", sep='')
                                x <- colorize(sum(raw.data$num_found) / sum(raw.data$num_max), ifelse(absoluteNumbers, yes=round(sum(raw.data$num_found)), no=""), enableColors)                        
                                if (extraColumn)
                                {
                                    s = paste("{\\subcolbeg\\begin{tabular}{", paste(rep("r",SUBCOLUMNS), collapse=""), "}", sep="")
                                    
                                    for (k in seq(ceiling(MAX_ERRORS / SUBCOLUMNS)))
                                    {
                                        for (l in seq(SUBCOLUMNS))
                                        {
                                            # output separate sensitivities for errors=0,..,5
                                            err = (k - 1) * SUBCOLUMNS + (l - 1)
                                            if (err > MAX_ERRORS)
                                                next
                                            
                                            if (l > 1)
                                                s = paste(s, "&")
                                            # from_err = (err - 1) * READ_LENGTHS[io] / 100.0;
                                            # to_err   =  err      * READ_LENGTHS[io] / 100.0;
                                            from_err = (err - 1) ;
                                            to_err   =  err      ;
                                            #if (err == MAX_ERRORS)
                                            #    to_err = from_err + 1
                                            X=subset(raw.data, from_err < error_rate & error_rate <= to_err)
                                            if (nrow(X) == 1 && X$num_max != 0)
                                            {
                                                text = ifelse(absoluteNumbers, yes=round(X$num_found), no="")
                                                s = paste(s, colorize(X$num_found / X$num_max, text, enableColors))
                                            }
                                            else
                                                s = paste(s, '--')
                                        }
                                        if (k == ceiling(MAX_ERRORS / SUBCOLUMNS))
                                            s = paste(s, "\\subcolvspace", sep="")
                                        s = paste(s, "\\\\", sep="")
                                    }
                                    s = paste(s, "\\end{tabular}\\subcolend}", sep="")
                                    x = paste(x, s)
                                }
                            }                           
                        }
                        else
                        {
                            print(paste("skip",RABEMA_FILE))
                            x = "--"
                        }
                        colheaders = paste(colheaders, "&\\multicolumn{1}{c}{", prefix_headers, colname, "}")
                        colheaders_units = paste(colheaders_units, "&\\multicolumn{1}{c}{", prefix_units, unit, "}")

                        if(REPORT_ABSOLUTE)
                        {
                            unit = gsub("Normalized", "Absolute", unit)
                            colheaders = paste(colheaders, "&\\multicolumn{1}{c}{", prefix_headers, colname, "}")
                            colheaders_units = paste(colheaders_units, "&\\multicolumn{1}{c}{", prefix_units, unit, "}")
                        }
                    }


                    if (grepl("^P_", col))
                    {
                        # performance results
                        subexp = sub("^P_", "", col)
                        RESOURCE_FILE = paste(RESULT_DIR, paste(dataset, mapper, "bam.res", sep='.'), sep='/')
                        
                        resFile = c()
                        resFileTS = c()
                        x = "--\\ \\ "
                        date = ""
                        
                        if (subexp == "time" )
                        {
                            colname = "Runtime"
                            unit = "[min:s]"
                            field = "wc_time"

                            if ((R = load_file(RESOURCE_FILE))$ok)
                            {
                                x = paste(secsToMinSec(sum(R$tsv[field])), "\\ \\ ", sep='')
                                date = paste(R$tsv$date[1], R$tsv$time[1], sep='\\\\')
                            } else
                                print(paste("skip",RESOURCE_FILE))
                        }

                        if (subexp == "throughput")
                        {
                            colname = "Throughput"
                            unit = "[Gbp/h]"
                            field = "wc_time"

                            if ((R = load_file(RESOURCE_FILE))$ok)
                                x = paste(format(round((READ_LENGTHS[io] * NUM_READS / sum(R$tsv[field])) * (3600/10^9), digits=2), nsmall=2), "\\ \\ ", sep='')
                            else
                                print(paste("skip",RESOURCE_FILE))
                        }

                        if (subexp == "memory")
                        {
                            colname = "Memory"
                            unit = "[GB]"
                            field = "rss_mem_peak"
                            
                            if ((R = load_file(RESOURCE_FILE))$ok)
                            {
                                maxMem = max(R$tsv[field])
                                x = format(round(maxMem/1024.0^2,2), nsmall=2)
                            } else
                                print(paste("skip",RESOURCE_FILE))
                        }
                                                                            
                        align = paste(align, "r", sep='')
                        colheaders = paste(colheaders, "&\\multicolumn{1}{r}{", prefix_headers, colname, "}")
                        colheaders_units = paste(colheaders_units, "&\\multicolumn{1}{r}{", prefix_units, unit, "}")
                    }

                    line = c(line, x)
                }
            }

            M = rbind(M, c(paste(prefix_mappers, MAPPERS_LABEL[mapper], space2), line))
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
