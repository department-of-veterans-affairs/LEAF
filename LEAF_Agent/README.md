# LEAF Agent

The LEAF Agent enables local site admins to configure and run automated tasks on a recurring basis.

Tasks can contain one or more instructions. The Agent supports the following instructions:
1. Take a specific action
2. Act based on a query
3. Act based on a tally of previous actions for a specific step
4. Hold a record for a specific duration
5. Update data based on a query
6. 🤖 Automatically Categorize content (Action)
    - The Agent cannot apply approval/disapproval/deny actions.
7. 🤖 Automatically Categorize content (Update Data)
8. 🤖 Automatically Label data (Update a data field)
9. 🤖 Automatically Label data (Update the record's title)

## Implementation Details

LEAF Agents have the same level of access as normal users, communicate with the same LEAF Application Programming Interface (API) endpoints, and are subject to the same access management rules.

Tasks encompass a series of instructions, which are executed for a specific Site and StepID. The corresponding workflow Step must have the LEAF Agent as a configured requirement.

If an error occurs during an instruction for a record, the agent will log the error and cancel subsequent instructions for that record.

Instructions that use LLMs do not have the ability to apply approval/disapproval/deny actions.
