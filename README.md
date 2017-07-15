# Rails Fullpage Cache

## Project setup

```sh
rails g model Author name:string age:integer email:string
rails g model Post title:string description:text author:belongs_to category:string dt:datetime position:float published:boolean
rails g model Detail description:text author:belongs_to
rails g model Tag name:string
rails g model PostTag post:belongs_to tag:belongs_to
```
