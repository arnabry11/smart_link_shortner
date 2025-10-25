module ApiDocs
  def self.generate
    {
      openapi: "3.0.0",
      info: {
        title: "Smart Link Shortener API",
        description: "API documentation for the Smart Link Shortener application",
        version: "1.0.0",
        contact: {
          name: "API Support",
          email: "support@example.com",
          url: "https://example.com/support"
        },
        license: {
          name: "MIT",
          url: "https://opensource.org/licenses/MIT"
        }
      },
      servers: [
        {
          url: "http://localhost:3000/api/v1",
          description: "Development server"
        }
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: :JWT,
            description: "JWT Authorization header using the Bearer scheme. Enter your token in the text input below."
          }
        }
      },
      paths: {
        '/auth/register': {
          post: {
            summary: "Register a new user",
            description: "Creates a new user account",
            tags: [ "Authentication" ],
            requestBody: {
              required: true,
              content: {
                'application/json': {
                  schema: {
                    type: :object,
                    required: [ :user ],
                    properties: {
                      user: {
                        type: :object,
                        required: [ :email, :password, :first_name, :last_name ],
                        properties: {
                          email: {
                            type: :string,
                            format: :email,
                            description: "User email address"
                          },
                          password: {
                            type: :string,
                            minLength: 6,
                            description: "User password"
                          },
                          first_name: {
                            type: :string,
                            description: "User first name"
                          },
                          last_name: {
                            type: :string,
                            description: "User last name"
                          }
                        }
                      }
                    }
                  },
                  example: {
                    user: {
                      email: "user@example.com",
                      password: "password123",
                      first_name: "John",
                      last_name: "Doe"
                    }
                  }
                }
              }
            },
            responses: {
              '201': {
                description: "User registered successfully",
                content: {
                  'application/json': {
                    schema: {
                      type: :object,
                      properties: {
                        user: {
                          type: :object,
                          properties: {
                            id: { type: :integer },
                            email: { type: :string },
                            first_name: { type: :string },
                            last_name: { type: :string }
                          }
                        },
                        token: {
                          type: :string,
                          description: "JWT authentication token"
                        }
                      }
                    }
                  }
                }
              },
              '422': {
                description: "Validation errors",
                content: {
                  'application/json': {
                    schema: {
                      type: :object,
                      properties: {
                        errors: {
                          type: :array,
                          items: { type: :string }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        },
        '/auth/login': {
          post: {
            summary: "Login user",
            description: "Authenticate user and return JWT token",
            tags: [ "Authentication" ],
            requestBody: {
              required: true,
              content: {
                'application/json': {
                  schema: {
                    type: :object,
                    required: [ :email, :password ],
                    properties: {
                      email: {
                        type: :string,
                        format: :email,
                        description: "User email address"
                      },
                      password: {
                        type: :string,
                        description: "User password"
                      }
                    }
                  },
                  example: {
                    email: "user@example.com",
                    password: "password123"
                  }
                }
              }
            },
            responses: {
              '200': {
                description: "Login successful",
                content: {
                  'application/json': {
                    schema: {
                      type: :object,
                      properties: {
                        user: {
                          type: :object,
                          properties: {
                            id: { type: :integer },
                            email: { type: :string },
                            first_name: { type: :string },
                            last_name: { type: :string }
                          }
                        },
                        token: {
                          type: :string,
                          description: "JWT authentication token"
                        }
                      }
                    }
                  }
                }
              },
              '401': {
                description: "Invalid credentials",
                content: {
                  'application/json': {
                    schema: {
                      type: :object,
                      properties: {
                        error: { type: :string }
                      }
                    }
                  }
                }
              }
            }
          }
        },
        '/auth/logout': {
          delete: {
            summary: "Logout user",
            description: "Invalidate user session",
            tags: [ "Authentication" ],
            security: [
              {
                bearerAuth: []
              }
            ],
            responses: {
              '200': {
                description: "Logout successful",
                content: {
                  'application/json': {
                    schema: {
                      type: :object,
                      properties: {
                        message: { type: :string }
                      }
                    }
                  }
                }
              },
              '401': {
                description: "Not authenticated",
                content: {
                  'application/json': {
                    schema: {
                      type: :object,
                      properties: {
                        error: { type: :string }
                      }
                    }
                  }
                }
              }
            }
          }
        },
        '/auth/forgot_password': {
          post: {
            summary: "Request password reset",
            description: "Send password reset instructions to user email",
            tags: [ "Authentication" ],
            requestBody: {
              required: true,
              content: {
                'application/json': {
                  schema: {
                    type: :object,
                    required: [ :email ],
                    properties: {
                      email: {
                        type: :string,
                        format: :email,
                        description: "User email address"
                      }
                    }
                  },
                  example: {
                    email: "user@example.com"
                  }
                }
              }
            },
            responses: {
              '200': {
                description: "Password reset instructions sent",
                content: {
                  'application/json': {
                    schema: {
                      type: :object,
                      properties: {
                        message: { type: :string }
                      }
                    }
                  }
                }
              }
            }
          }
        },
        '/auth/reset_password': {
          post: {
            summary: "Reset password",
            description: "Reset user password using reset token",
            tags: [ "Authentication" ],
            requestBody: {
              required: true,
              content: {
                'application/json': {
                  schema: {
                    type: :object,
                    required: [ :token, :password ],
                    properties: {
                      token: {
                        type: :string,
                        description: "Password reset token"
                      },
                      password: {
                        type: :string,
                        minLength: 6,
                        description: "New password"
                      }
                    }
                  },
                  example: {
                    token: "reset-token-here",
                    password: "newpassword123"
                  }
                }
              }
            },
            responses: {
              '200': {
                description: "Password reset successful",
                content: {
                  'application/json': {
                    schema: {
                      type: :object,
                      properties: {
                        message: { type: :string }
                      }
                    }
                  }
                }
              },
              '422': {
                description: "Invalid or expired token",
                content: {
                  'application/json': {
                    schema: {
                      type: :object,
                      properties: {
                        error: { type: :string }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  end
end
