## Changes between 4.1.1 and 4.2.0

#### Required Ruby Version >= 2.7.0
#### Upgrade httprb dependency to version ~> 5.1.0
#### Upgrade Bunny dependency to version ~> 2.19.0

## Changes between 1.5.1 and 2.0.0

**This release uses the new SpaceBunny API and is incompatible with previous versions**


## Changes between 1.1.0 and 1.2.0

**This release includes minor breaking API changes**

#### Removed `auto_recover` option

This is an API break and if you previously used the option 
now it will be ignored.
Use instead Bunny's `recover_from_connection_close` 
to obtain the same behaviour. 
Take a look at [Bunny doc](http://rubybunny.info/articles/guides.html) for more details.  
