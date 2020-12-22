# Commands Module

### Description
The **commands module** lets you create chat and console commands easily. It takes care of verifying the type of each argument before running the command.

### Creating a command
```
RVR.Commands.register( name:string, argument names:table, argument types:table, user group:number, command:function, description:string )
```
Where:
- Name is the name of the command to be used when running it
- Argument names is a table of strings containing the names of all arguments to be passed in the command in order
- Argument types is a table of strings containing the types of each argument in order
- User group is a number determining which user group can use this command
- Command is the function that will run once all arguments are verified. It's first argument is the player that ran the function and all following arguments are the arguments that have been verified
- Description (Optional) is a string that will be used by the help command to give information about the command

### Argument types
The **commands module** implements five types.
- `int` Checks for an integer value, should it be negative or not
- `float` Checks for a float value, should it also be negative or not
- `string` Checks for a string
- `boolean` Allows for these boolean values:
  - "true", "yes", "enable", "enabled" and "1" will be converted to `true`
  - "false", "no", "disable", "disabled" and "0" will be converted to `false`
- `player` Checks for a player in-game. It works with the player's name as well as their steam id. Passing `^` will pass the player that ran the command and `@` will pass the player being aimed at by whoever ran the command.
- `color` Checks for an hexadecimal color code with optional alpha (#RRGGBBAA) such as #FF0000 for red or #FFFFFF00 for transparent.

### Creating a type
Custom argument types can be created using:
```
RVR.Commands.addType( type:string, checker:function )
```
Where:
- Type is the name of the type to be used in the **argument types** table of the `register` function
- Checker is a function that takes the argument to be verified and the player that ran the command to then perform tests on the argument to make sure it is valid. If the argument fails your tests, you need to `return nil, <An error message>` in order to show the player what went wrong. If it passed your tests then you need to `return <your argument>` in the proper format (Converted to a number for example).

### Using a command
Once a command has been created it can be ran from the chat using `!<command name> <arguments>` or through the console using `rvr <command name> <arguments>`.
If the command is missing an argument, a message showing all arguments and their types will be displayed.
If one of the argument is invalid, a message showing which argument was wrong will be displayed.

### The Help command
The **commands module** implements a help command that can be called like explained in the **Using a command** section.
It needs one argument, the name of an existing command. It will show the description of that command as well as it's usage like so:
```
Usage: <command name> <argument name:argument type> ...
Description: <The optional description>
```