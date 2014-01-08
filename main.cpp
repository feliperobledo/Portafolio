#include <iostream>
#include <vector>
#include <map>

/******************************************************************************
    Description: The Base of a message. This class is the pivot for
    every message.
******************************************************************************/
class IMessageBase
{
    public:
        virtual ~IMessageBase(void) {}
        virtual const char* MessageName(void) const = 0;
};


/******************************************************************************
    Description: A proxy message used to demonstrate 
    message system.
******************************************************************************/
class InputMessage : public IMessageBase
{
    public:
        InputMessage(void) : IMessageBase() 
        {
            std::cout << "Constructing InputMessage" << std::endl;
        }

        ~InputMessage(void)
        {
        }

        virtual const char* MessageName(void) const
        {
            return "InputMessage";
        }
};

/******************************************************************************
    Description: A base used by the MessageSubspace to holds all types
    of message binds.
    A Binding binds an object's method to receive a specific
    event message. When the event occurs, the event's data is passed
    to the bound method that processes the data.
******************************************************************************/
class BindingBase
{
    public:
        virtual ~BindingBase(void) {};
        virtual void DeliverMessage(IMessageBase* message) = 0;
};

/******************************************************************************
    Description: A Binding binds an object's method to receive a specific
    event message. When the event occurs, the event's data is passed
    to the bound specific object's method that processes the data.
******************************************************************************/
template <typename ObjectType, typename MessageType, typename Function>
class Binding : public BindingBase
{
    public:        
        Binding(ObjectType* object,Function method) : BindingBase(),
                                                      m_pMessageCall(method),
                                                      m_pObject(object)
        {
            std::cout << "Binding an object to a message type" << std::endl;
        }

        virtual void DeliverMessage(IMessageBase* message)
        {
            std::cout << "Delivering Message" << std::endl;
            MessageType* actualMessage = reinterpret_cast<MessageType*>(message);            
            (m_pObject->*m_pMessageCall)(actualMessage);
        } 

    private:
        Function m_pMessageCall;
        ObjectType* m_pObject;
};

/******************************************************************************
    Description: The message subspace is in charge of holding all
    bindings for all messages as well as deliver triggered event messages
    to the respective bindings.
******************************************************************************/
class MessageSubspace
{
    /******************************************************************************
                Public MessageSubspace Constructors and Destructors
    ******************************************************************************/
    public:
        MessageSubspace(void)
        {
            std::cout << "Constructing MessageSubspace" << std::endl;
        }

        ~MessageSubspace(void)
        {
            std::cout << "Cleaning up all MessageSusbspace allocated data" << std::endl;
            BindingCleanUp();
        }

    /******************************************************************************
            Public MessageSubspace Basic Initialization and Cleaning Methods
    ******************************************************************************/
    public:
        void Initialize(void)
        {
            std::cout << "Initializing MessageSubspace" << std::endl;
            RegisterMessage("InputMessage");
        }

        void BindingCleanUp(void)
        {
            std::cout << "Binding Object CleanUp" << std::endl;

            auto iter = m_Bindings.begin();
            while(iter != m_Bindings.end())
            {
                auto binding_iter = (iter->second).begin();
                while( binding_iter != (iter->second).end() )
                {
                    delete (*binding_iter);
                    ++binding_iter;
                }
                (iter->second).clear();
                ++iter;
            }
        }

    /******************************************************************************
                  Public MessageSubspace Object-Message Registration
    ******************************************************************************/
    public:
        void RegisterMessage(const char* messageName)
        {
            //Creates a field with the message name in the message database if the message
            //type name does not exist.
            if(m_Bindings.find(messageName) == m_Bindings.end())
            {
                std::cout << "Creating new binding vector for " << messageName << " messages" << std::endl;
                m_Bindings.insert( std::make_pair(messageName,Bindings()) );
            }
        }

        //The main function that allows any object with the method ProcessMessage
        //to bind to a certain type of message.
        template <typename MessageType, typename ObjectType>
        void Bind(ObjectType& object,void (ObjectType::*Method)(MessageType*), const char* MessageName)
        {
            auto iter = m_Bindings.find(MessageName);
            if(iter != m_Bindings.end())
            {
                std::cout << "Binding an object to " << MessageName << std::endl;                
                AddNewBinding(object,Method,MessageName);
            }
        }

    /******************************************************************************
             Private MessageSubspace Object-Message Registration Helpers
    ******************************************************************************/
    private:
        template <typename ObjectType, typename MessageType>
        void AddNewBinding(ObjectType& object,void (ObjectType::*Method)(MessageType*), const char* MessageName)
        {
            typedef void (ObjectType::*MethodType)(MessageType*);
            BindingBase* newBinding = new Binding<ObjectType,MessageType,MethodType>(&object,Method);
            this->m_Bindings[MessageName].push_back(newBinding);
        }

    /******************************************************************************
                  Public MessageSubspace Message Delivery
    ******************************************************************************/
    public:
        template <typename MessageType>
        void TransmitMessage(MessageType& message) 
        {
            std::cout << "Transmitting " << message.MessageName() << std::endl;

            auto i_msgBinding = m_Bindings.find(message.MessageName());
            auto iter = (i_msgBinding->second).begin();
            auto end = (i_msgBinding->second).end();
            while(iter != end)
            {
                (*iter)->DeliverMessage(&message);
                ++iter;
            }
        }

    /******************************************************************************
                       Private MessageSubspace Typedefs
    ******************************************************************************/
    private:
        typedef std::vector<BindingBase*> Bindings; //The binding per object
        typedef std::map<const char*,Bindings> MessageBindings;

    /******************************************************************************
                       Private MessageSubspace Members
    ******************************************************************************/
    private:
        MessageBindings m_Bindings;

    /******************************************************************************
             Private MessageSubspace Object-Message Registration Helpers
    ******************************************************************************/
    private:
        template <typename ObjectType, typename MessageType>
        void AddNewBinding(ObjectType& object,void (ObjectType::*Method)(MessageType*), const char* MessageName)
        {
            typedef void (ObjectType::*MethodType)(MessageType*);
            BindingBase* newBinding = new Binding<ObjectType,MessageType,MethodType>(&object,Method);
            this->m_Bindings[MessageName].push_back(newBinding);
        }
};

//Gameobjects need to know about an existing message subspace in order to 
//register to messages
MessageSubspace* g_MessageSusbspace;

/******************************************************************************
    Description: Sample game object to test messsaging system
******************************************************************************/
class GameObject
{
    public:
        GameObject(void)
        {
            std::cout << "Constructing a GameObject" << std::endl;
        }

        ~GameObject(void)
        {
        }

    /******************************************************************************
            Public GameObject Basic Initialization and Cleaning Methods
    ******************************************************************************/
    public:
        void Initialize(void)
        {
            std::cout << "Binding GameObject to messages" << std::endl;
            g_MessageSusbspace->Bind<InputMessage>(*this,&GameObject::ProcessInputMessage,"InputMessage");
        }

    /******************************************************************************
                    Public GameObject Message Processing Methods
    ******************************************************************************/
    public:
        void ProcessInputMessage(InputMessage* message)
        {
            std::cout << "Gameobject Receives InputMessage" << std::endl;
        }
};

int main(void)
{
    //Construct and Initialize the subspaces
    MessageSubspace messageSubspace;
    messageSubspace.Initialize();
    g_MessageSusbspace = &messageSubspace;

    GameObject gObject[10];
    for(int i = 0; i < 10; ++i)
    {
        gObject[i].Initialize();
    }

    //Transmit a sample input message 
    InputMessage iMessage;
    messageSubspace.TransmitMessage(iMessage);
    
    return 0;
}