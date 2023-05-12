Work in progress...


---


# ERC721C as Composable
[ERC721Composable](https://github.com/eldief/ERC721C/blob/main/src/ERC721Composable.sol) is the base contract that can be expanded via `ERC721Components`.  

Provides functionalities for:
- Whitelisting `ERC721Component` collections
- Link `ERC721Component` to `ERC721Composable`
- Render linked `ERC721Component`


# ERC721C as Component
[ERC721Component](https://github.com/eldief/ERC721C/blob/main/src/ERC721Component.sol) is the base contract that can expand `ERC721Component`.  

Provides functionalities for:
- Be rendered by `ERC721Composable`


# ERC721C as Composable Component
[ERC721ComposableComponent](https://github.com/eldief/ERC721C/blob/main/src/ERC721ComposableComponent.sol) is the base contract that act as both `ERC721Components` and `ERC721Component`.  

Provides functionalities for:
- Whitelisting `ERC721Component` collections
- Link `ERC721Component` to `ERC721Composable`
- Render linked `ERC721Component`
- Be rendered by `ERC721Composable`


# Components and Rendering
`ERC721Composable` and `ERC721ComposableComponent` delegate components verification gas usage to view functions that usually are called externally like `ERC721.tokenURI`, allowing to not increase gas costs for transfers and keeping it low for linking/unlinking `ERC721Components`.  

This is achieved by not checking if a linked component is valid while being set (exist, is owned or is in the correct slot), while just rendering or ignoring it at run-time during `ERC721.tokenURI` function 


# Custom Data
All contracts packs variables in less slots as possible, saving run-time gas while also providing free space freely customizable by contracts building on `ERC721C` called "Custom Data"; in each contract description is specified the Layout defined for each packed variable.  
A library to manage "Custom Data" with basic types is also provided: [`PackingLib`](https://github.com/eldief/ERC721C/blob/main/src/libraries/PackingLib.sol). 

# Hooks
Each base contract expose many hooks that can be customized to provide rendering functionalities:

`ERC721Composable`:
- _beforeRender -> Executed before rendering
- _onRender -> Executed while rendering
- _afterRender -> Executed after rendering
- _beforeComponentRender -> Executed before rendering a component
- _afterComponentRender -> Executed after rendering a component


`ERC721Component`:
- _beforeRender -> Executed before rendering
- _onRender -> Executed while rendering
- _afterRenderInternal -> Executed after rendering internally
- _afterRenderExternal -> Executed after rendering externally

`ERC721ComposableComponent`:
- _beforeRender -> Executed before rendering
- _onRender -> Executed while rendering
- _afterRenderInternal -> Executed after rendering internally
- _afterRenderExternal -> Executed after rendering externally
- _beforeComponentRender -> Executed before rendering a component
- _afterComponentRender -> Executed after rendering a component

# Working with ERC721C
WIP...

---