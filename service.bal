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
