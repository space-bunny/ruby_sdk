## Changes betwen 1.1.0 and 1.2.0

**This release includes minor breaking API changes**

#### Removed `auto_recover` option

This is an API break and if you previously used the option 
now it will be ignored.
Use instead Bunny's `recover_from_connection_close` 
to obtain the same behaviour. 
Take a look at [Bunny doc](http://rubybunny.info/articles/guides.html) for more details.  
