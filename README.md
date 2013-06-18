TiCustomPhotoAlbum
==================

# Description

This iOS module extends the Ti SDK for saving images into custom photo album by @hank7444.

This moudle only have one method called addCustomAlbumAndSaveImage, can create 

custom album(if the album does not exist) and save image.


## Referencing the module in your Titanium Mobile application ##

Simply add the following lines to your `tiapp.xml` file:

    <modules>
        <module version="0.2" platform="iphone">ti.customphotoalbum</module>
    </modules>

and add this line in your app.js file:

  require('ti.customphotoalbum');

### Module methods

* `addCustomAlbumAndSaveImage(image, albumName)`
  * params
		* image - image blob,
		* album - string albumName
    

# Dependence

  1. AssetsLibrary.framework
  2. MobileCoreServices.framework


# REFERENCE:

- [iOS5: Saving photos in custom photo album (+category for download)][1]  
- [Kjuly github ALAssetsLibrary-CustomPhotoAlbum][2]

[1]: http://www.touch-code-magazine.com/ios5-saving-photos-in-custom-photo-album-category-for-download/
[2]: https://github.com/Kjuly/ALAssetsLibrary-CustomPhotoAlbum
