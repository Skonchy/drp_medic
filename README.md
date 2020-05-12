# drp_medic
Adaptation of DRP_Police for EMS/Medics

This script relies on functions from DRP_Police, DRP_ID, DRP_Death, and DRP_JobCore  
  
This script has the following commands  
  - /hire <department> <charid> ex: /hire ems 1  
    - This command will add the target character to the medic table, allowing them to go on/off duty at Crusade Medical  
      
  - /promote <department> <charid> ex: /promote ems 1  
    - This command will increase the target character's rank in the department by 1 assuming the source has a higher rank than the target and sufficient minimum rank to manage department members.  
    
  - /demote <department> <charid> ex: /demote ems 1  
    - This command will decrease the target character's rank in the department by 1 and fire the target if their rank would be 0 after the demotion assuming the source has a a sufficient minimum rank to manage department members.  
      
  - /911 <department> <message> ex: /911 ems "Help my friend is dead"  
    - This command sends the desired message to all members of the department specified. When department members receive the call, they are given the option to accept the call which marks the call location on the member's map, or decline it, removing the call blip and ignoring the call.  
    
  - /heal  
    - This command will get the nearest player to the source and heal that person of their wounds, assuming the source is onduty as EMS.  
      
  - /revive  
    - This command will get the nearest player that is dead to the source and revive them after playing an animation, assuming the source is onduty as EMS.  
    
