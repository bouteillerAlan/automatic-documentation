# automatic-documentation
:pencil: [wip] small sh for automatic doc

## nldr

allows to find a comment in each file for a project and auto generate the documentation

for the moment the format is ``\\ comment``, before the function, on one line or multi line

markdown is fully functionnal, just use it in the comment line ``// ## title lvl2``

#### example a

```
// this function make something great (great:string)
async function(great: string) {
... some code
```

#### example b

```
// this function make something great (great:string)
// other line of comment
async function(great: string) {
... some code
```
