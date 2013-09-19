/**
 * Copyright (c) 2012, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

public virtual with sharing class SObjectDomain 
{
	public List<SObject> Records { get; protected set;}

	//Why not have the domain changable, we should always be working on a set, we mod the set why not overwrite it?
	//SOC would say dont care about the source, you work with the set you have
	public virtual SObjectDomain setRecords(List<SObject> objects) { this.Records = objects; return this; }
	
	public Schema.DescribeSObjectResult SObjectDescribe {get; private set;}
	
	public SObjectDomain(List<SObject> sObjectList)
	{
		Records = sObjectList;
		
		SObjectDescribe = Records.getSObjectType().getDescribe();
	}
	
	public virtual void applyDefaults() { }
		
	public virtual void validate() { }
	
    public virtual void beforeInsert() 
    { 
    	applyDefaults(); 
    }
    
    public virtual void beforeUpdate(Map<Id,SObject> oldSObjectMap) { }
    
    public virtual void beforeDelete() { }
    
    public virtual void afterInsert()
    {
    	if(!SObjectDescribe.isCreateable())
    	   throw new DomainException('Permission to create an ' + SObjectDescribe.getName() + ' dennied.');
    	   
    	validate(); 
    }
    
    public virtual void afterUpdate(Map<Id,SObject> oldSObjectMap) 
    {
    	if(!SObjectDescribe.isUpdateable())
    	   throw new DomainException('Permission to udpate an ' + SObjectDescribe.getName() + ' dennied.');
    	   
    	validate(); 
    }
    
    public virtual void afterDelete() 
    {
    	if(!SObjectDescribe.isDeletable())
    	   throw new DomainException('Permission to delete an ' + SObjectDescribe.getName() + ' dennied.');
    }	

    //added as a method to simply get the working ID set - JK Nov 5, 2012
    public Set<Id> getIdSet() {
    	Set<Id> idSet = new Set<Id>();
    	for(SObject record : this.Records)
    		idSet.add(record.Id);
    	return idSet;
    }
	
	public interface IConstructable
	{
		SObjectDomain construct(List<SObject> sObjectList);
	}
	
	/**
	 * Method constructs the given Domain class with the current Trigger context 
	 * before calling the applicable override methods such as beforeInsert, beforeUpdate etc.
	 **/
	public static void triggerHandler(Type domainClass)
	{
		String domainClassName = domainClass.getName();
		Type constructableClass = Type.forName(domainClassName+'.Constructor');
		IConstructable constructor = (IConstructable) constructableClass.newInstance();
		if(Trigger.isBefore)
	    {
	        if(Trigger.isInsert) constructor.construct(Trigger.new).beforeInsert();
	        else if(Trigger.isUpdate) constructor.construct(Trigger.new).beforeUpdate(Trigger.oldMap);
	        else if(Trigger.isDelete) constructor.construct(Trigger.oldMap.values()).beforeDelete();
	    }
	    else
	    {
	        if(Trigger.isInsert) constructor.construct(Trigger.new).afterInsert();
	        else if(Trigger.isUpdate) constructor.construct(Trigger.new).afterUpdate(Trigger.oldMap);
	        else if(Trigger.isDelete) constructor.construct(Trigger.oldMap.values()).afterDelete();
	    }		
	}

	public SObjectDomain dedupeRecordsById() {
		Set<Id> alreadyInListIds = new Set<Id>();
		List<SObject> records = new List<SObject>(); 
		for(SObject record : this.records) {
			Id recordId = (Id)record.get('Id');
			if(!alreadyInListIds.contains(recordId)) {
				records.add(record);
				alreadyInListIds.add(recordId);
			}
		}
		this.records = records;
		return this;
	}
	
	public class DomainException extends Exception
	{
	}
}