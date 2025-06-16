# LEAF Agent

The LEAF Agent enables local site admins to configure and run automated tasks on a recurring basis.

Tasks contain instructions such as:
1. Applying Actions defined by an admin
2. Applying Actions based on a tally of previous actions for a specific step, defined by an admin
3. Applying Actions after a specific duration, defined by an admin
4. Applying Actions based on specific conditions, defined by an admin
5. Applying Actions based on automatic categorization using a Large Language Model (LLM), with context provided from an admin
6. Updating a single-select field using a LLM, with context provided from an admin

## Implementation Details

LEAF Agents have the same level of access as normal users, communicate with the same LEAF Application Programming Interface (API) endpoints, and is subject to the same access management rules.

Tasks encompass a series of instructions, which are executed for a specific Site and StepID. The corresponding workflow Step must have the LEAF Agent as a configured requirement.

Instructions within a task operate on sets of records, rather than individual records. If an error occurs during an instruction, the agent will log the error, stop processing the rest of the set, and cancel subsequent instructions.

Instructions that use LLMs do not have the ability to apply approval/disapproval/deny actions.
