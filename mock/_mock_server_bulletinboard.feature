Feature: mock server for bulletinboard
    Background:
        * configure cors = true

        * def userList = read("data/initial_users.json")

        * def postList = read("data/initial_posts.json")

        * def covertFileToImageFuc =
            """
                function(imageFileInputStream) {
                    var bytes = imageFileInputStream.readAllBytes();
                    return bytes;
                }
            """

        * def findUserBySpecificTypeFuc = 
            """
                function(type, keyword) {
                    if(type == "id") {
                        for(var index = 0; index < userList.length; index++) {
                            if(userList[index].id == keyword) {
                                return userList[index];
                            }
                        }
                    } else if(type == "email") {
                        for(var index = 0; index < userList.length; index++) {
                            if(userList[index].email == keyword) {
                                return userList[index];
                            }
                        }
                    } else if(type == "token") {
                        for(var index = 0; index < userList.length; index++) {
                            if(userList[index].token == keyword && !userList[index].deleted_user_id) {
                                return userList[index];
                            }
                        }
                    }
                    return null;
                }
            """

        * def checkAuthToken = 
            """
                function(header) {
                    if(header["Authorization"] && header["Authorization"][0] && header["Authorization"][0].split(" ").length == 2) {
                        var user = findUserBySpecificTypeFuc("token", header["Authorization"][0].split(" ")[1]);
                        if(user) {
                            return true;
                        }
                    }
                    return false;
                }
            """

        * def randomString = 
            """
                function(length) {
                    var chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
                    var result = "";
                    for (var i = length; i > 0; --i) result += chars[Math.floor(Math.random() * chars.length)];
                    return result;
                }

            """
        
        * def loginFuc = 
            """
                function(email, password) {
                    var response = {};
                    var user = findUserBySpecificTypeFuc("email", email);
                    if(user && user.password === password) {
                        response = {
                            id: user.id,
                            name: user.name,
                            email: user.email,
                            token: user.token,
                            token_type: "Bearer"
                        }
                    return {response: response, status: 200};
                    } else {
                        response = {
                            error: "Incorrect Email or Password."
                        };
                    return {response: response, status: 401};
                    }
                }
            """
        
        * def getAvatorFuc =
            """
                function(id) {
                    var user = findUserBySpecificTypeFuc("id", id);
                    if(user) {
                        var avator = read("target/" + user.profile_path);
                        return covertFileToImageFuc(avator)
                    }
                    return null;
                }
            """
        
        * def getUserList =
            """
                function(header) {
                    var response = {
                        error : "Unauthorized"
                    };
                    var isAuthorized = checkAuthToken(header)
                    if(isAuthorized) {
                        var tmpUserList = [];
                        for(var index = 0; index < userList.length; index++) {
                            var tmpUser = {};
                            tmpUser.id = userList[index].id;
                            if(userList[index].name) tmpUser.name = userList[index].name;
                            if(userList[index].email) tmpUser.email = userList[index].email;
                            if(userList[index].profile_path) tmpUser.profile_path = userList[index].profile_path;
                            if(userList[index].phone) tmpUser.phone = userList[index].phone;
                            if(userList[index].address) tmpUser.address = userList[index].address;
                            if(userList[index].dob) tmpUser.dob = userList[index].dob;
                            if(userList[index].deleted_user_id) tmpUser.deleted_user_id = userList[index].deleted_user_id;
                            tmpUser.created_user_id = userList[index].created_user_id;
                            tmpUser.updated_user_id = userList[index].updated_user_id;
                            tmpUserList.push(tmpUser);
                        }
                        response = {
                            user_list : tmpUserList
                        }
                        return {response: response, status: 200}
                    }
                    return {response: response, status: 401};
                }
            """
        
        * def saveProfilePicture = 
            """
                function(header, imageByte) {
                    var time = java.lang.System.currentTimeMillis();
                    var avatorPath = "images/avators/" + time + ".png";
                    var response = {
                        error : "Unauthorized"
                    };
                    var isAuthorized = checkAuthToken(header)
                    if(isAuthorized) {
                        karate.write(imageByte, avatorPath)
                        response = {
                            profile_path : avatorPath
                        }
                        return {response: response, status: 200}
                    }
                    return {response: response, status: 401};
                }
            """

        * def createUser = 
            """
                function(header, request) {
                    var response = {
                        error : "Unauthorized"
                    };
                    var createdUser = findUserBySpecificTypeFuc("token", header["Authorization"][0].split(" ")[1]);
                    if(createdUser) {
                        var newUser = {};
                        newUser.id = userList.length + 1;
                        if(request.name) newUser.name = request.name;
                        if(request.email) newUser.email = request.email;
                        if(request.password) newUser.password = request.password;
                        if(request.profile_path) newUser.profile_path = request.profile_path;
                        if(request.phone) newUser.phone = request.phone;
                        if(request.address) newUser.address = request.address;
                        if(request.dob) newUser.dob = request.dob;
                        newUser.created_user_id = createdUser.id;
                        newUser.updated_user_id = createdUser.id;
                        newUser.token = randomString(100);
                        karate.appendTo(userList, newUser);
                        response = {
                            message : "Created New User Successfully."
                        }
                        return {response: response, status: 200}
                    }
                    return {response: response, status: 401};
                }
            """

        * def createUser = 
            """
                function(header, request) {
                    var response = {
                        error : "Unauthorized"
                    };
                    var createdUser = findUserBySpecificTypeFuc("token", header["Authorization"][0].split(" ")[1]);
                    if(createdUser) {
                        var newUser = {};
                        newUser.id = userList.length + 1;
                        if(request.name) newUser.name = request.name;
                        if(request.email) newUser.email = request.email;
                        if(request.password) newUser.password = request.password;
                        if(request.profile_path) newUser.profile_path = request.profile_path;
                        if(request.phone) newUser.phone = request.phone;
                        if(request.address) newUser.address = request.address;
                        if(request.dob) newUser.dob = request.dob;
                        newUser.created_user_id = createdUser.id;
                        newUser.updated_user_id = createdUser.id;
                        newUser.token = randomString(100);
                        karate.appendTo(userList, newUser);
                        response = {
                            message : "Created New User Successfully."
                        }
                        return {response: response, status: 200}
                    }
                    return {response: response, status: 401};
                }
            """

        * def updateUser = 
            """
                function(header, request, userId) {
                    var response = {
                        error : "Unauthorized"
                    };
                    if(!checkAuthToken(header)) {
                        return {response: response, status: 401};
                    }
                    var updatedUser = findUserBySpecificTypeFuc("token", header["Authorization"][0].split(" ")[1]);
                    if(updatedUser) {
                        var updated = false;
                        for(var index = 0; index < userList.length; index++) {
                            if(userList[index].id == userId) {
                                if(request.name) userList[index].name = request.name;
                                if(request.phone) userList[index].phone = request.phone;
                                if(request.address) userList[index].address = request.address;
                                if(request.dob) userList[index].dob = request.dob;
                                userList[index].updated_user_id = updatedUser.id;
                                updated = true;
                                break;
                            }
                        }
                        if(updated) {
                            response = {
                                message : "Updated New User Successfully."
                            };
                            return {response: response, status: 200};
                        }
                        response = {
                            error : "Invalid user!"
                        };
                        return {response: response, status: 422};
                    }
                }
            """

        * def deleteUser = 
            """
                function(header, request, userId) {
                    var response = {
                        error : "Unauthorized"
                    };
                    if(!checkAuthToken(header)) {
                        return {response: response, status: 401};
                    }
                    var deletedUser = findUserBySpecificTypeFuc("token", header["Authorization"][0].split(" ")[1]);
                    if(deletedUser) {
                        var deleted = false;
                        for(var index = 0; index < userList.length; index++) {
                            if(userList[index].id == userId) {
                                userList[index].deleted_user_id = deletedUser.id;
                                deleted = true;
                                break;
                            }
                        }
                        if(deleted) {
                            response = {
                                message : "Deleted User Successfully."
                            };
                            return {response: response, status: 200};
                        }
                        response = {
                            error : "Invalid user!"
                        };
                        return {response: response, status: 422};
                    }
                }
            """

        * def getPostList =
            """
                function(header) {
                    var response = {
                        error : "Unauthorized"
                    };
                    var isAuthorized = checkAuthToken(header)
                    if(isAuthorized) {
                        var tmpPostList = [];
                        for(var index = 0; index < postList.length; index++) {
                            var tmpPost = {};
                            tmpPost.id = postList[index].id;
                            if(postList[index].title) tmpPost.title = postList[index].title;
                            if(postList[index].description) tmpPost.description = postList[index].description;
                            if(postList[index].deleted_user_id) tmpPost.deleted_user_id = postList[index].deleted_user_id;
                            tmpPost.created_user_id = postList[index].created_user_id;
                            tmpPost.updated_user_id = postList[index].updated_user_id;
                            tmpPostList.push(tmpPost);
                        }
                        response = {
                            post_list : tmpPostList
                        }
                        return {response: response, status: 200}
                    }
                    return {response: response, status: 401};
                }
            """
        
        * def createPost = 
            """
                function(header, request) {
                    var response = {
                        error : "Unauthorized"
                    };
                    var createdUser = findUserBySpecificTypeFuc("token", header["Authorization"][0].split(" ")[1]);
                    if(createdUser) {
                        var newPost = {};
                        newPost.id = postList.length + 1;
                        if(request.title) newPost.title = request.title;
                        if(request.description) newPost.description = request.description;
                        newPost.created_user_id = createdUser.id;
                        newPost.updated_user_id = createdUser.id;
                        karate.appendTo(postList, newPost);
                        response = {
                            message : "Created New Post Successfully."
                        }
                        return {response: response, status: 200}
                    }
                    return {response: response, status: 401};
                }
            """

        * def updatePost = 
            """
                function(header, request, postId) {
                    var response = {
                        error : "Unauthorized"
                    };
                    if(!checkAuthToken(header)) {
                        return {response: response, status: 401};
                    }
                    var updatedUser = findUserBySpecificTypeFuc("token", header["Authorization"][0].split(" ")[1]);
                    if(updatedUser) {
                        var updated = false;
                        for(var index = 0; index < postList.length; index++) {
                            if(postList[index].id == postId) {
                                if(request.title) postList[index].title = request.title;
                                if(request.description) postList[index].description = request.description;
                                postList[index].updated_user_id = updatedUser.id;
                                updated = true;
                                break;
                            }
                        }
                        if(updated) {
                            response = {
                                message : "Updated New Post Successfully."
                            };
                            return {response: response, status: 200};
                        }
                        response = {
                            error : "Invalid user!"
                        };
                        return {response: response, status: 422};
                    }
                }
            """

        * def deletePost =
            """
                function(header, request, postId) {
                    var response = {
                        error : "Unauthorized"
                    };
                    if(!checkAuthToken(header)) {
                        return {response: response, status: 401};
                    }
                    var deletedUser = findUserBySpecificTypeFuc("token", header["Authorization"][0].split(" ")[1]);
                    if(deletedUser) {
                        var deleted = false;
                        for(var index = 0; index < postList.length; index++) {
                            if(postList[index].id == postId) {
                                postList[index].deleted_user_id = deletedUser.id;
                                deleted = true;
                                break;
                            }
                        }
                        if(deleted) {
                            response = {
                                message : "Deleted Post Successfully."
                            };
                            return {response: response, status: 200};
                        }
                        response = {
                            error : "Invalid user!"
                        };
                        return {response: response, status: 422};
                    }
                }
            """


    # POST /auth/login
    Scenario: pathMatches("/auth/login") && methodIs("post")
        * def email = request.email
        * def password = request.password
        * def ctx = loginFuc(email, password)
        * def responseStatus = ctx.status
        * def response = ctx.response

    # POST /auth/logout
    Scenario: pathMatches("/auth/logout") && methodIs("post")
        * def responseStatus = 204

    # GET /get/avator/{id}
    Scenario: pathMatches("/get/avator/{id}") && methodIs("get")
        * eval id = pathParams.id
        * def response = getAvatorFuc(id)

    # GET /user/list
    Scenario: pathMatches("/user/list") && methodIs("get")
        * def ctx = getUserList(requestHeaders)
        * def responseStatus = ctx.status
        * def response = ctx.response

    # Post /save/profile_picture
    Scenario: pathMatches("/save/profile_picture") && methodIs("post")
        * def ctx = saveProfilePicture(requestHeaders, requestBytes)
        * def responseStatus = ctx.status
        * def response = ctx.response
    
    # Post /create/user
    Scenario: pathMatches("/create/user") && methodIs("post")
        * def ctx = createUser(requestHeaders, request)
        * def responseStatus = ctx.status
        * def response = ctx.response

    # Put /update/user/{id}
    Scenario: pathMatches("/update/user/{id}") && methodIs("put")
        * eval userId = pathParams.id
        * print userId
        * def ctx = updateUser(requestHeaders, request, userId)
        * def responseStatus = ctx.status
        * def response = ctx.response

    # Delete /delete/user/{id}
    Scenario: pathMatches("/delete/user/{id}") && methodIs("delete")
        * eval userId = pathParams.id
        * def ctx = deleteUser(requestHeaders, request, userId)
        * def responseStatus = ctx.status
        * def response = ctx.response

    # Get /post/list
        Scenario: pathMatches("/post/list") && methodIs("get")
        * def ctx = getPostList(requestHeaders)
        * def responseStatus = ctx.status
        * def response = ctx.response

    # Post /create/post
    Scenario: pathMatches("/create/post") && methodIs("post")
        * def ctx = createPost(requestHeaders, request)
        * def responseStatus = ctx.status
        * def response = ctx.response

    # Put /update/post/{id}
    Scenario: pathMatches("/update/post/{id}") && methodIs("put")
        * eval postId = pathParams.id
        * def ctx = updatePost(requestHeaders, request, postId)
        * def responseStatus = ctx.status
        * def response = ctx.response

    # /delete/post/{id}
    Scenario: pathMatches("/delete/post/{id}") && methodIs("delete")
        * eval postId = pathParams.id
        * def ctx = deletePost(requestHeaders, request, postId)
        * def responseStatus = ctx.status
        * def response = ctx.response
