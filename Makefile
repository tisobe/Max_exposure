############################
# Change the task name!
############################
TASK = Acis_hist

include /data/mta4/MTA/include/Makefile.MTA

BIN  = acis_dose_extract_stat_data.perl acis_dose_extract_stat_data_month.perl acis_dose_get_data.perl acis_dose_make_cum.perl acis_dose_make_data_html.perl acis_dose_plot_exposure_stat.perl hrc_dose_extract_stat_data.perl hrc_dose_extract_stat_data_month.perl hrc_dose_get_data.perl hrc_dose_make_data_html.perl hrc_dose_plot_exposure_stat.perl hrc_dose_get_data_full_rage.perl hrc_dose_plot_exposure_stat_section.perl hrc_dose_make_data_html_full_range.perl hrc_dose_dff_comp_stat_month.perl hrc_dose_acc_comp_stat_month.perl hrc_dose_make_cum_add_to_last.perl dose_plot_html_for_plot.perl acis_dose_seprate_ccd.perl hrc_does_update_html.perl
DOC  = README

install:
ifdef BIN
	rsync --times --cvs-exclude $(BIN) $(INSTALL_BIN)/
endif
ifdef DATA
	mkdir -p $(INSTALL_DATA)
	rsync --times --cvs-exclude $(DATA) $(INSTALL_DATA)/
endif
ifdef DOC
	mkdir -p $(INSTALL_DOC)
	rsync --times --cvs-exclude $(DOC) $(INSTALL_DOC)/
endif
ifdef IDL_LIB
	mkdir -p $(INSTALL_IDL_LIB)
	rsync --times --cvs-exclude $(IDL_LIB) $(INSTALL_IDL_LIB)/
endif
ifdef CGI_BIN
	mkdir -p $(INSTALL_CGI_BIN)
	rsync --times --cvs-exclude $(CGI_BIN) $(INSTALL_CGI_BIN)/
endif
ifdef PERLLIB
	mkdir -p $(INSTALL_PERLLIB)
	rsync --times --cvs-exclude $(PERLLIB) $(INSTALL_PERLLIB)/
endif
ifdef WWW
	mkdir -p $(INSTALL_WWW)
	rsync --times --cvs-exclude $(WWW) $(INSTALL_WWW)/
endif
