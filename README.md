# HOW TO
Download an IMG file from (http://www.uahirise.org/), and place it in the (data/) directory. Make sure ISIS and the golang compiler are installed. Then, download the golang dependencies:
`make goget`
Finally, assuming the .IMG file you downloaded is called 'DTEEC_000000_0000_000000_0000_000.IMG', call:
`make DTEEC_000000_0000_000000_0000_000.fits`
You will find the output traversability map in (figures/maps/ESP_000000_0000)
