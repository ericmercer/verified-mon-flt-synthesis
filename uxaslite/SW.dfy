module SW {
  const TASK_ID := 42

  predicate WELL_FORMED_TASK_ID(id : int) {
    (id == TASK_ID)
  }

  datatype Waypoint = 
    Waypoint(Latitude : real, Longitude : real, Altitude : real) {
      predicate WELL_FORMED_WAYPOINT() {
          (this.Latitude >= -90.0 && this.Latitude <= 90.0)
        && (this.Longitude >= -180.0 && this.Longitude <= 180.0) 
        && (this.Altitude >= 10000.0 && this.Altitude <= 15000.0)
      }
    }

  datatype AutomationRequest = AutomationRequest(TaskID : int) {
    predicate WELL_FORMED_AUTOMATION_REQUEST() {
      WELL_FORMED_TASK_ID(this.TaskID)
    }
  }

  datatype AutomationResponse = 
    AutomationResponse(TaskID : int, Length : int, Waypoints : seq<Waypoint>) {
      predicate WELL_FORMED_AUTOMATION_RESPONSE() {
           (WELL_FORMED_TASK_ID(this.TaskID))
        && (forall waypoint : Waypoint :: 
             waypoint in this.Waypoints ==> waypoint.WELL_FORMED_WAYPOINT())
      }
    }
  
  datatype EventDataPort<T> = None() | Some(value:T)
  datatype EventPort = None() | Some()

  class AI {
    static 
    method {:extern} step(AutomationRequest : EventDataPort<AutomationRequest>, 
                          AirVehicleLocation : EventDataPort<Waypoint>) 
      returns (AutomationResponse : EventDataPort<AutomationResponse>)
      requires AutomationRequest.Some? ==> 
        AutomationRequest.value.WELL_FORMED_AUTOMATION_REQUEST()
      requires AirVehicleLocation.Some? ==> 
        AirVehicleLocation.value.WELL_FORMED_WAYPOINT()
  }

  class WaypointManager {
    static 
    method {:extern} step(AutomationResponse : EventDataPort<AutomationResponse>,
                          AirVehicleLocation : EventDataPort<Waypoint>)
      returns (Start : EventPort, Waypoint : EventDataPort<Waypoint>)
      requires AutomationResponse.Some? ==> 
        AutomationResponse.value.WELL_FORMED_AUTOMATION_RESPONSE()
      requires AirVehicleLocation.Some? ==>
        AirVehicleLocation.value.WELL_FORMED_WAYPOINT()
      ensures Waypoint.Some? ==> AirVehicleLocation.Some?
      ensures Start.Some? <==> AutomationResponse.Some?
      ensures Start.Some? ==> Waypoint.Some?
      ensures Waypoint.Some? ==> Waypoint.value.WELL_FORMED_WAYPOINT()
  }

  trait SW {
    const MAX_LATENCY := 1

    ghost var isPending : bool;
    ghost var latency : int;
    ghost var alertPersistent : bool;

    predicate isBounded(latency : int) {
      (0 <= latency && latency <= MAX_LATENCY)
    }

    method step(AutomationRequest : EventDataPort<AutomationRequest>,
                AirVehicleLocation : EventDataPort<Waypoint>)
      returns (Waypoint : EventDataPort<Waypoint>,
                Start : EventPort,
                Alert : EventPort)
      requires AutomationRequest.Some? ==> 
        AutomationRequest.value.WELL_FORMED_AUTOMATION_REQUEST()
      requires AirVehicleLocation.Some? ==> 
        AirVehicleLocation.value.WELL_FORMED_WAYPOINT()
      requires AutomationRequest.Some? ==> !isPending

      modifies `isPending, `latency, `alertPersistent
      ensures isPending <==> (   (AutomationRequest.Some? && Start.None?)
                              || old(isPending))
      ensures latency == 
        (if AutomationRequest.Some? then 0 else old(latency) + 1)
      ensures alertPersistent <==> 
        Alert.None? || (Alert.Some? && old(alertPersistent))

      ensures Waypoint.Some? ==> AirVehicleLocation.Some?
      ensures Waypoint.Some? ==> Waypoint.value.WELL_FORMED_WAYPOINT()

      ensures Start.Some? ==> Waypoint.Some?
      ensures Start.Some? ==> isBounded(latency)

      ensures (isPending && !isBounded(latency)) ==> Alert.Some?
      ensures alertPersistent
  }

  // class SWOrig extends SW {

  //   method step(AutomationRequest : EventDataPort<AutomationRequest>,
  //               AirVehicleLocation : EventDataPort<Waypoint>)
  //     returns (Waypoint : EventDataPort<Waypoint>,
  //               Start : EventPort,
  //               Alert : EventPort)
  //     requires AutomationRequest.Some? ==> 
  //       AutomationRequest.value.WELL_FORMED_AUTOMATION_REQUEST()
  //     requires AirVehicleLocation.Some? ==> 
  //       AirVehicleLocation.value.WELL_FORMED_WAYPOINT()
  //     requires AutomationRequest.Some? ==> !isPending

  //     modifies `isPending, `latency, `alertPersistent
  //     ensures isPending <==> (   (AutomationRequest.Some? && Start.None?) 
  //                             || old(isPending))
  //     ensures latency == (if AutomationRequest.Some? then 0 else old(latency) + 1)
  //     ensures alertPersistent <==> 
  //       Alert.None? || (Alert.Some? && old(alertPersistent))

  //     ensures Waypoint.Some? ==> AirVehicleLocation.Some?
  //     ensures Waypoint.Some? ==> Waypoint.value.WELL_FORMED_WAYPOINT()

  //     ensures Start.Some? ==> Waypoint.Some?
  //     ensures Start.Some? ==> isBounded(latency)

  //     ensures (isPending && !isBounded(latency)) ==> Alert.Some?
  //     ensures alertPersistent 
  //   {
  //     isPending := (   (AutomationRequest.Some? && Start.None?) 
  //                   || isPending);
  //     latency := (if AutomationRequest.Some? then 0 else latency + 1);
  //     alertPersistent := Alert.None? || (Alert.Some? && alertPersistent);

  //     var AutomationResponse : EventDataPort<AutomationResponse> := 
  //       AI.step(AutomationRequest, AirVehicleLocation);
  //     Start, Waypoint := WaypointManager.step(AutomationResponse, AirVehicleLocation);
  //   }
  // }

  class Filter {
    static 
    method {:extern} step(Input : EventDataPort<AutomationResponse>)
      returns (Output : EventDataPort<AutomationResponse>)
      ensures Output == 
        (if (Input.Some? && Input.value.WELL_FORMED_AUTOMATION_RESPONSE()) then
          Input
         else
          EventDataPort<AutomationResponse>.None())
  }

  // class Monitor {
  //   const is_latched := true
  //   const MAX_LATENCY := 1

  //   ghost var historicallyNotRequest : bool;
  //   ghost var notRequestSinceResponse : bool;  
  //   ghost var latency : int;
  //   ghost var alert : bool;
  
  //   constructor ()
  //     ensures historicallyNotRequest
  //     ensures notRequestSinceResponse;
  //     ensures latency == 0
  //     ensures alert == false
  //   {
  //     historicallyNotRequest := true;
  //     notRequestSinceResponse := true;
  //     latency := 0;
  //     alert := false;
  //   }

  //   predicate isBounded(latency : int) {
  //     (0 <= latency && latency <= MAX_LATENCY)
  //   }

  //   method {:external} step(Response : EventDataPort<AutomationResponse>,
  //               Request : EventDataPort<AutomationRequest>)
  //     returns (Alert : EventPort, Output : EventDataPort<AutomationResponse>)
      
  //     requires Request.Some? ==> 
  //       (historicallyNotRequest || notRequestSinceResponse)

  //     modifies `historicallyNotRequest, `notRequestSinceResponse
  //     ensures historicallyNotRequest == 
  //       (Request.None? && old(historicallyNotRequest))
  //     ensures notRequestSinceResponse == 
  //       (Response.Some? || (Request.None? && old(notRequestSinceResponse)))

  //     modifies `latency
  //     ensures latency == (if Request.Some? then 0 else old(latency) + 1)

  //     ensures Output ==
  //       if (Response.Some? && isBounded(old(latency))) then
  //         Response
  //       else
  //         EventDataPort<AutomationResponse>.None
  //     ensures Alert == EventPort.None
  // }

  class Monitor {
    const is_latched := true
    const MAX_LATENCY := 2

    ghost var policy : bool;  
    ghost var alert : bool;
    ghost var isPending : bool;  
    ghost var latency : int;
    
    constructor ()
      ensures policy == true
      ensures alert == false
      ensures isPending == false
      ensures latency == 0
    {
      policy := true;
      alert := false;
      isPending := false;
      latency := 0;
    }

    predicate isBounded(latency : int) {
      (0 <= latency && latency < MAX_LATENCY)
    }

    // isPending == not response since request
     
    method {:external} step(Response : EventDataPort<AutomationResponse>,
                Request : EventDataPort<AutomationRequest>)
      returns (Alert : EventPort, Output : EventDataPort<AutomationResponse>)
      
      requires Request.Some? ==> !isPending

      modifies `isPending
      // request TRIGGERS (not response)
      ensures isPending == (Response.None? && (Request.Some? || old(isPending)))
      
      modifies `latency
      ensures latency == (if Request.Some? then 1 else old(latency) + 1)

      modifies `policy
      // deponds on input assumption to not reset latency _before_ it is checked
      ensures policy == (    (old(isPending) ==> isBounded(latency))
                          && (Response.Some? ==> (old(isPending) || Request.Some?)))
 
      modifies `alert
      ensures alert == (!policy || (is_latched && old(alert)))

      ensures Alert == (if alert then EventPort.Some else EventPort.None)
      ensures Output ==
        if (!alert && Response.Some?) then
          Response
        else
          EventDataPort<AutomationResponse>.None
  }

  method {:test} should_doNothing_when_noInput() {
    var monitor : Monitor := new Monitor();
    var alert : EventPort;
    var output : EventDataPort<AutomationResponse>;
    assert !monitor.isPending;
    assert monitor.policy;
    assert !monitor.alert;
    alert, output := monitor.step(
      EventDataPort<AutomationResponse>.None, 
      EventDataPort<AutomationRequest>.None);
    assert alert.None?;
    assert output.None?;
  }

  method {:test} should_alertAndNotOutput_when_responseWithoutRequest() {
    var waypoint : Waypoint := Waypoint(42.0, 42.0, 42.0);
    var value : AutomationResponse := AutomationResponse(42, 1, [waypoint]);
    var automationResponse : EventDataPort<AutomationResponse> := 
      EventDataPort<AutomationResponse>.Some(value);

    var monitor : Monitor := new Monitor();
    var alert : EventPort;
    var output : EventDataPort<AutomationResponse>;
    alert, output := monitor.step(
      automationResponse, 
      EventDataPort<AutomationRequest>.None);
    assert alert.Some?;
    assert output.None?;
  }

  method {:test} should_notAlertAndOutput_when_responseAndRequest() {
    var waypoint : Waypoint := Waypoint(42.0, 42.0, 42.0);
    var value : AutomationResponse := AutomationResponse(42, 1, [waypoint]);
    var automationResponse : EventDataPort<AutomationResponse> := 
      EventDataPort<AutomationResponse>.Some(value);
    var automationRequest : EventDataPort<AutomationRequest> := 
      EventDataPort<AutomationRequest>.Some(AutomationRequest(TASK_ID));
    
    var monitor : Monitor := new Monitor();
    var alert : EventPort;
    var output : EventDataPort<AutomationResponse>;
    alert, output := monitor.step(automationResponse, automationRequest);
    assert alert.None?;
    assert output.Some?;
    assert (output == automationResponse);
  }

  method {:test} should_notAlertAndOutput_when_responseOneStepAfterRequest() {
    var waypoint : Waypoint := Waypoint(42.0, 42.0, 42.0);
    var value : AutomationResponse := AutomationResponse(42, 1, [waypoint]);
    var automationResponse : EventDataPort<AutomationResponse> := 
      EventDataPort<AutomationResponse>.Some(value);
    var automationRequest : EventDataPort<AutomationRequest> := 
      EventDataPort<AutomationRequest>.Some(AutomationRequest(TASK_ID));
    
    var monitor : Monitor := new Monitor();
    var alert : EventPort;
    var output : EventDataPort<AutomationResponse>;
    alert, output := monitor.step(
      EventDataPort<AutomationResponse>.None, 
      automationRequest);
    assert alert.None?;
    assert output.None?;
    alert, output := monitor.step(
      automationResponse, 
      EventDataPort<AutomationRequest>.None);
    assert alert.Some?;
    assert output.None?;
  }

  method {:test} should_alertAndNotOutput_when_noResponseTwoStepsAfterRequest() {
    var waypoint : Waypoint := Waypoint(42.0, 42.0, 42.0);
    var value : AutomationResponse := AutomationResponse(42, 1, [waypoint]);
    var automationResponse : EventDataPort<AutomationResponse> := 
      EventDataPort<AutomationResponse>.Some(value);
    var automationRequest : EventDataPort<AutomationRequest> := 
      EventDataPort<AutomationRequest>.Some(AutomationRequest(TASK_ID));
    
    var monitor : Monitor := new Monitor();
    var alert : EventPort;
    var output : EventDataPort<AutomationResponse>;
    alert, output := monitor.step(
      EventDataPort<AutomationResponse>.None, 
      automationRequest);
    assert alert.None?;
    assert output.None?;
    alert, output := monitor.step(
      EventDataPort<AutomationResponse>.None, 
      EventDataPort<AutomationRequest>.None);
    assert alert.Some?;
    assert output.None?;
  }

  method {:test} should_alwaysAlert_when_onceAlerted() {
    var waypoint : Waypoint := Waypoint(42.0, 42.0, 42.0);
    var value : AutomationResponse := AutomationResponse(42, 1, [waypoint]);
    var automationResponse : EventDataPort<AutomationResponse> := 
      EventDataPort<AutomationResponse>.Some(value);
    var automationRequest : EventDataPort<AutomationRequest> := 
      EventDataPort<AutomationRequest>.Some(AutomationRequest(TASK_ID));
    
    var monitor : Monitor := new Monitor();
    var alert : EventPort;
    var output : EventDataPort<AutomationResponse>;
    alert, output := monitor.step(
      automationResponse, 
      EventDataPort<AutomationRequest>.None);
    assert alert.Some?;
    assert output.None?;
    alert, output := monitor.step(
      automationResponse, 
      automationRequest);
    assert alert.Some?;
    assert output.None?;
    alert, output := monitor.step(
      EventDataPort<AutomationResponse>.None, 
      EventDataPort<AutomationRequest>.None);
    assert alert.Some?;
    assert output.None?;
  }

  class SWCyber {
    const MAX_LATENCY := 1

    ghost var alert : bool;
    ghost var isPending : bool;  
    ghost var latency : int;

    var Monitor : Monitor;

    predicate isBounded(latency : int) {
      (0 <= latency && latency <= MAX_LATENCY)
    }

    constructor ()
      ensures alert == false
      ensures isPending == false
      ensures latency == 0
      ensures fresh(Monitor)
    {
      alert := false;
      isPending := false;
      latency := 0;
      Monitor := new Monitor();
    }

    method step(AutomationRequest : EventDataPort<AutomationRequest>,
                AirVehicleLocation : EventDataPort<Waypoint>)
                returns (Waypoint : EventDataPort<Waypoint>,
                         Start : EventPort,
                         Alert : EventPort)
      requires AutomationRequest.Some? ==> 
        AutomationRequest.value.WELL_FORMED_AUTOMATION_REQUEST()
      requires AirVehicleLocation.Some? ==> 
        AirVehicleLocation.value.WELL_FORMED_WAYPOINT()
      requires AutomationRequest.Some? ==> !isPending

      modifies `alert;
      ensures alert == (Alert.Some? || old(alert))

      modifies `isPending
      ensures isPending == (Start.None? && (AutomationRequest.Some? || old(isPending)))
      
      modifies `latency
      ensures latency == (if AutomationRequest.Some? then 1 else old(latency) + 1)

      ensures Waypoint.Some? ==> AirVehicleLocation.Some?
      ensures Waypoint.Some? ==> Waypoint.value.WELL_FORMED_WAYPOINT()

      ensures Start.Some? ==> Waypoint.Some?
      ensures Start.Some? ==> isBounded(latency)
    
      // ensures alert ==> Alert.Some?
      
      modifies Monitor
      requires AutomationRequest.Some? ==> !Monitor.isPending;
    {
      var AutomationResponse : EventDataPort<AutomationResponse> := 
        AI.step(AutomationRequest, AirVehicleLocation);
      AutomationResponse := Filter.step(AutomationResponse);
      Alert, AutomationResponse := Monitor.step(AutomationResponse, AutomationRequest);
      Start, Waypoint := WaypointManager.step(AutomationResponse, AirVehicleLocation);
      assert AutomationResponse.Some? <==> Start.Some?;
      alert := (Alert.Some? || old(alert));
      latency := (if AutomationRequest.Some? then 1 else old(latency) + 1);
      isPending := (Start.None? && (AutomationRequest.Some? || old(isPending)));
      if (AutomationRequest.Some?) {
        assert Monitor.latency == 1;
        assert latency == 1;
        assert Monitor.latency == latency;
      } else {
        assert Monitor.latency == old(Monitor.latency) + 1;
        assert latency == old(latency) + 1;
        // assert Monitor.latency == latency;
      }
    }
  }
}