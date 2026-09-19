; Replace CPKTemplate with a unique project prefix and command name.

axlCmdRegister("CPKTemplate" 'CPKTemplate)

procedure(CPKTemplateWriteReport(reportFile records)
    let((fp)
        fp = outfile(reportFile)
        if(fp then
            fprintf(fp "CPKTemplate report\n\n")
            foreach(record records
                fprintf(fp "%L\n" record)
            )
            close(fp)
            t
        else
            axlMsgPut("CPKTemplate: cannot create report %s" reportFile)
            nil
        )
    )
)

procedure(CPKTemplate()
    let((design records reportFile reportOK)
        design = axlDBGetDesign()
        records = nil
        reportFile = "./CPKTemplate.log"

        ; Query the database directly and populate records here.
        ; Avoid visibility/find-filter dependencies for read-only audits.

        reportOK = CPKTemplateWriteReport(reportFile records)
        when(reportOK
            axlUIViewFileCreate(reportFile "CPKTemplate" nil)
        )

        axlMsgPut("CPKTemplate: %d records" length(records))
        records
    )
)
