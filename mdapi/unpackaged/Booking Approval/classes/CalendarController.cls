public class CalendarController {
	@auraEnabled
	public static List<User> getUsers(){
		return [SELECT Id, Name,LastName, FirstName FROM User WHERE isActive=:true LIMIT 50000];
	}

	@auraEnabled
	public static String getUserId(){
		return UserInfo.getUserId();
	}


	@auraEnabled
	public static Boolean createNewEvent( String start_time, String end_time, String user_id, String what_id, String sobjectName, String title ){
		Booking__c e = new Booking__c();
		e.start_time__c = DateTime.valueOf(start_time);
		e.end_time__c = DateTime.valueOf(end_time);
		e.Name = title;
		e.OwnerId = user_id;
        
		if( sobjectName == 'Lead' || sobjectName == 'Contact' ){
			e.Contact__c = what_id;	
		}
		else{
			e.Contact__c = what_id;	
		}		
		INSERT e;
		return e.Id != null;
	}

	@auraEnabled
	public static String getEvents( DateTime start_time, DateTime end_time, String user_id ){
        Date dStartDate = Date.valueof(start_time);
        Date dEndDate   = Date.valueof(end_time);

        
	    List<String> listClassName = new LIST<String>();
	    for( Integer i = 1; i< 100; i++ ){
	      listClassName.add( 'UserEvent-'+i );
	    }
	    LIST<CustomEvent> listEvent = new LIST<CustomEvent>();
	    for( Booking__c a:[
	      SELECT start_time__c, end_time__c, Owner.Name, Name 
	      FROM Booking__c
	      WHERE
	        ( 
	          // User selector
	          OwnerId =: user_id 
	        ) AND
	        (
	          (
	            // scope contains event
	            start_time__c >=: dStartDate AND
	            end_time__c <=: dEndDate
	          ) OR
	          (
	            // scope partically contains event
	            (
	              start_time__c >=: dStartDate AND
	              start_time__c <=: dEndDate
	            ) OR
	            (
	              end_time__c >=: dStartDate AND
	              end_time__c <=: dEndDate
	            )
	          ) OR
	          (
	            // event contains scope
	            start_time__c <=: dStartDate AND
	            end_time__c >=: dEndDate
	          )
	        )
	      LIMIT 50000  
	      ] 
	    ){
	      CustomEvent tmp = new CustomEvent(a);      
	      listEvent.add( tmp );
	    }
	    return JSON.serialize(listEvent).replace('end_time_x', 'end');		
	}


	public class CustomEvent{
		public String title {get;set;}
		public String start {get;set;}
		public String end_time_x {get;set;}
		public String id {get;set;}
		public String className {get;set;}

		public CustomEvent( Booking__c e ){
			this.title = e.Name;
			this.start = String.valueof( e.start_time__c );
			this.end_time_x = String.valueof( e.end_time__c );
			this.id = e.Id;
		}
	}

}