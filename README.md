# Dependencies

For this program to work, you will need to have [Golang](https://golang.org/doc/install) installed. Once Golang is installed, make sure you downloaded the required dependencies:
Then, download the golang dependencies by calling:
```
make goget
```
You will also need the [ISIS](https://isis.astrogeology.usgs.gov/documents/InstallGuide/) libraries installed and loaded in your path. Finally, you will need MATLAB for the final image processing.

# HOWTO
Download an IMG file that contains a DTM from the [HiRISE DTM catalog](http://www.uahirise.org/), and place it in the `data` directory. Assuming the .IMG file you downloaded is called `DTEEC_000000_0000_000000_0000_000.IMG`, call:
```
make DTEEC_000000_0000_000000_0000_000.fits
```
You will find the output traversability map in `figures/maps/ESP_000000_0000`
