import ballerina/http;
import ballerina/sql;

service /api on new http:Listener(3000) {

    //Resource function to Delete a programme by programme code and returns the removed Programme.
    resource function delete delete_programme/[string programme_code]() returns Programmes[]|error {
        // Retrieve the programme details before deletion
        stream<Programmes, sql:Error?> programmeStream = db->query(`
        SELECT * 
        FROM Programmes
        WHERE programme_code = ${programme_code}
        `);

        Programmes[] programmeList = [];
        check from Programmes programme in programmeStream
            do {
                programmeList.push(programme);
            };

        // If no results are found, return an error
        if programmeList.length() == 0 {
            return error("Programme not found.");
        }

        // First, delete related entries in the Courses table
        _ = check db->execute(`
        DELETE FROM Courses
        WHERE programme_code = ${programme_code}
    `);

        // Then, delete the programme
        _ = check db->execute(`
        DELETE FROM Programmes
        WHERE programme_code = ${programme_code}
    `);

        // Return the deleted programme details
        return programmeList;
    }

    //Resouce Function to Retrieve all programmes due for review
    resource function get review_due() returns Reviews[]|error {
        stream<Reviews, sql:Error?> reviewsStream = db->query(`
            SELECT *
            FROM Reviews r
            WHERE r.review_due_date <= CURRENT_DATE
        `);

        Reviews[] reviewList = [];
        check from Reviews reviews in reviewsStream
            do {
                reviewList.push(reviews);
            };

        // If no results are found, return an error
        // if reviewList.length() == 0 {
        //     return error("No Programme is Due");
        // }

        return reviewList;
    }

    //Resource function to Retrieve all programmes that belong to the same faculty
    resource function get faculty_programme/[string faculty]() returns Programmes[]|error {
        stream<Programmes, sql:Error?> programmeStream = db->query(`
            SELECT *
            FROM Programmes p
            WHERE p.faculty = ${faculty}
        `);

        Programmes[] programmeList = [];
        check from Programmes programme in programmeStream
            do {
                programmeList.push(programme);
            };

        // If no results are found, return an error
        // if reviewList.length() == 0 {
        //     return error("No Programme is Due");
        // }

        return programmeList;
    }

}
