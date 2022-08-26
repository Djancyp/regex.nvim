# Regex Nvim

Helps you to live test your regex from your code.
## Demo

![Demo](https://github.com/Djancyp/nvim-plugin-demo/blob/main/regex.nvim/images/demo.gif)
## Installation

```lua
use "Djancyp/regex.nvim"
```
```lua
require('regex-nvim').Setup()
```
## Usage
### Toggle command
You need to run this command while your cursor is on the regex. Please check the demo.
```vim
:RegexHelper
```
### Set Multiple Paths for World-lists 
```lua
require('regex-nvim').Setup({
  paths:{
    emails = "<path to world-list>"
    dates = "<path to world-list>"
  }
})
```
### Mods
Ones you attach the regex helper.
#### Normal Mode
you can switch in between different regex line.
#### Insert Mode
you can change your regex and will live update the helper buffer.
#### Insert Mode in Helper Buffer.
As soon as you start to type your last attached regex will try to validate
 
## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)
