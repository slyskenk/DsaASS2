import ballerina/graphql;
import ballerina/http;
import ballerinax/mongodb;

type User record {
    string id;
    string firstName;
    string lastName;
    string jobTitle;
    string position;
    string role;
    string supervisorId;
};

type Objective record {
    string id;
    string name;
    int percentage;
};

type KPI record {
    string id;
    string name;
    int target;
    int score;
    string userId;
};

// Define the MongoDB connection configuration.
mongodb:ConnectionConfig mongoConfig = {
    connection: {
        host: "localhost",
        port: 27017,
        auth: {
            username: "",
            password: ""
        },
        options: {
            sslEnabled: false,
            serverSelectionTimeout: 5000
        }
    },
    databaseName: "performance_mgmt_db"
};

// Create a MongoDB client.
mongodb:Client mongoClient = check new (mongoConfig);

configurable string usersCollection = "Users";
configurable string objectivesCollection = "Objectives";
configurable string kpisCollection = "KPIs";

@graphql:ServiceConfig {
    graphiql: {
        enabled: true,
    // Path is optional, if not provided, it will be dafulted to `/graphiql`.
    path: "/"
    }
}
service /graphql on new graphql:Listener(4000) {

    remote function createObjective(Objective objective) returns string {

        var doc = <map<json>>objective.toJson();
        var insertedId = check mongoClient->insert(doc, objectivesCollection);
        return objective.id;
    }

    remote function deleteObjective(string objectiveId) returns string|error {
        var deleteResult = check mongoClient->delete(objectivesCollection, {id: objectiveId});
        return "yes";
    }


    remote function assignSupervisor(string userId, string supervisorId) returns boolean {
        var user = check mongoClient->findOne(usersCollection, {id: userId});
        if (user != null) {
            user.supervisorId = supervisorId;
            check mongoClient->update(usersCollection, {id: userId}, user);
            return true;
        } else {
            return false;
        }
    }

    remote function approveKPIs(string[] kpiIds) returns boolean {
        // Logic to approve KPIs
        foreach var kpiId in kpiIds {
            var kpi = check kpisCollection.findOne("id", kpiId);
            if (kpi != null) {
                // Update the KPI status to approved
                // You may add a "status" field in the KPI record to track the status
                kpi.status = "Approved";
                check kpisCollection.update("id", kpiId, kpi);
            }
        }
        return true;
    }

    remote function deleteKPI(string kpiId) returns boolean {
        var deleteResult = check kpisCollection.delete("id", kpiId);
        return deleteResult.deletedCount > 0;
    }

    remote function updateKPI(KPI kpi) returns boolean {
        var kpiDoc = <map<json>>kpi.toJson();
        var updateResult = check kpisCollection.update("id", kpi.id, kpiDoc);
        return updateResult.matchedCount > 0;
    }

    remote function getKPIsBySupervisor(string supervisorId) returns KPI[] {
        var kpiList = check kpisCollection.find("userId", supervisorId);
        return kpiList.toArray();
    }

    remote function gradeKPI(string kpiId, int score) returns boolean {
        var kpi = check kpisCollection.findOne("id", kpiId);
        if (kpi != null) {
            kpi.score = score;
            check kpisCollection.update("id", kpiId, kpi);
            return true;
        } else {
            return false;
        }
    }

    remote function createKPI(KPI kpi) returns string {
        var kpiDoc = <map<json>>kpi.toJson();
        var insertedId = check mongoClient->insert(kpiDoc, kpisCollection);
        //check kpisCollection.insert(kpiDoc);
        return kpi.id;
    }

    remote function getScore(string userId) returns int {
        var kpiList = check kpisCollection.find("userId", userId);
        int totalScore = 0;
        foreach var kpi in kpiList {
            totalScore = totalScore + kpi.score;
        }
        return totalScore;
    }

    remote function gradeSupervisor(string supervisorId, int score) returns boolean {
        var user = check usersCollection.findOne("id", supervisorId);
        if (user != null) {
            user.score = score;
            check usersCollection.update("id", supervisorId, user);
            return true;
        } else {
            return false;
        }
    }
}
