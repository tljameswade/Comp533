from tkinter import *
from tkinter import messagebox
from tkinter import font
from tkinter.ttk import Treeview
import psycopg2
import csv

conn = psycopg2.connect("dbname='postgres' user='ricedb' host='localhost' password='admin'")

# Open a cursor to perform database operations
cur = conn.cursor()


class Application(Frame):
    def __init__(self, master=None):
        Frame.__init__(self, master)
        self.grid(column=0, row=0)
        self.grid_configure(padx=10, pady=10)
        self.smallFont = font.Font(family='Helvetica', size=10)
        self.createWidgets()

    def createWidgets(self):
        Label(self, text='Comp533 Project', font=font.Font(family='Comic Sans MS', size=18))\
            .grid(column=0, row=0, columnspan=3)
        Label(self, text='Authors: Suozhi Qi, Haoyuan Xia', font=font.Font(family='Comic Sans MS', size=13))\
            .grid(column=0, row=1, columnspan=3)

        # Read data from a CVS File
        Label(self, text='Read data from: ').grid(row=2, column=0, sticky='E', pady=(15, 0))
        readInput = Entry(self, width=18)
        readInput.grid(row=2, column=1, pady=(15, 0))
        Button(self, text='Read', command=lambda: self.readData(readInput)).grid(row=2, column=2, pady=(15, 0))

        # Save data to a CVS File
        Label(self, text='Save data to: ', pady=10).grid(row=3, column=0, sticky='E')
        writeInput = Entry(self, width=18)
        writeInput.grid(row=3, column=1)
        Button(self, text='Save', command=lambda: self.writeData(writeInput)).grid(row=3, column=2)

        # Upsert date to a specific table
        Label(self, text='Upsert a row of data to:', font=font.Font(family='Comic Sans MS', size=15))\
            .grid(row=4, column=0, sticky='W', pady=(10, 0))
        v = StringVar()
        v.set('initial string')
        Radiobutton(self, text='Org', variable=v, value='Org').grid(row=5, column=0, sticky='W')
        Radiobutton(self, text='Meet', variable=v, value='Meet').grid(row=5, column=1, sticky='W')
        Radiobutton(self, text='Participant', variable=v, value='Participant').grid(row=5, column=2, sticky='W')
        Radiobutton(self, text='Leg', variable=v, value='Leg').grid(row=6, column=0, sticky='W')
        Radiobutton(self, text='Stroke', variable=v, value='Stroke').grid(row=6, column=1, sticky='W')
        Radiobutton(self, text='Distance', variable=v, value='Distance').grid(row=6, column=2, sticky='W')
        Radiobutton(self, text='Event', variable=v, value='Event').grid(row=7, column=0, sticky='W')
        Radiobutton(self, text='StrokeOf', variable=v, value='StrokeOf').grid(row=7, column=1, sticky='W')
        Radiobutton(self, text='Heat', variable=v, value='Heat').grid(row=7, column=2, sticky='W')
        Radiobutton(self, text='Swim', variable=v, value='Swim').grid(row=8, column=0, sticky='W')
        Button(self, text='Update Or Insert Data', command=lambda: self.upsertData(v.get())).grid(row=8, column=1)

        # Specific queries
        Label(self, text='Specific queries: ', font=font.Font(family='Comic Sans MS', size=15))\
            .grid(row=9, column=0, sticky='W', pady=(20, 0))

        Label(self, text='Meet Name *').grid(row=10, column=0, sticky='E')
        meetInput = Entry(self, width=15)
        meetInput.grid(row=10, column=1, sticky='W')
        Button(self, text='Display Heat Sheet', width=15, command=lambda: self.display('M2H', meetInput.get()))\
            .grid(row=10, column=2, sticky='W')
        Label(self, text='(heat sheet for this meet)', font=self.smallFont).grid(row=11, column=1, columnspan=2, sticky='E')

        Button(self, text='Display Scores', width=15, command=lambda: self.display('M2S', meetInput.get()))\
            .grid(row=12, column=2, sticky='W')
        Label(self, text='(scores for each school, calculated as follows)', font=self.smallFont) \
            .grid(row=13, column=1, columnspan=3, sticky='E')

        Label(self, text='Participant Id').grid(row=14, column=0, sticky='E')
        participantInput = Entry(self, width=15)
        participantInput.grid(row=14, column=1, sticky='W')
        Button(self, text='Display Heat Sheet', width=15,
               command=lambda: self.display('PM2H', participantInput.get(), meetInput.get()))\
            .grid(row=14, column=2, sticky='W')
        Label(self, text='(limited to this swimmer, including relays)', font=self.smallFont)\
            .grid(row=15, column=1, columnspan=2, sticky='E')

        Label(self, text='Organization Id').grid(row=16, column=0, sticky='E')
        schoolInput = Entry(self, width=15)
        schoolInput.grid(row=16, column=1, sticky='W')
        Button(self, text='Display Heat Sheet', width=15,
               command=lambda: self.display('OM2H', schoolInput.get(), meetInput.get()))\
            .grid(row=16, column=2, sticky='W')
        Label(self, text='(heat sheet limited to this school)', font=self.smallFont) \
            .grid(row=17, column=1, columnspan=2, sticky='E')

        Button(self, text='Display Names', width=15,
               command=lambda: self.display('OM2S', schoolInput.get(), meetInput.get()))\
            .grid(row=18, column=2, sticky='W')
        Label(self, text='(names of the competing swimmers)', font=self.smallFont) \
            .grid(row=19, column=1, columnspan=2, sticky='E')

        Label(self, text='Event Id').grid(row=20, column=0, sticky='E')
        eventInput = Entry(self, width=15)
        eventInput.grid(row=20, column=1, sticky='W')
        Button(self, text='Display All Results', width=15,
               command=lambda: self.display('EM2H', eventInput.get(), meetInput.get()))\
            .grid(row=20, column=2, sticky='W')
        Label(self, text='(heat results sorted by time)', font=self.smallFont) \
            .grid(row=21, column=1, columnspan=2, sticky='E')


    def readData(self, readInput):
        try:
            with open(readInput.get(), 'r') as f:
                reader = csv.reader(f)
                tableName = ""
                for row in reader:
                    if row[0][0] == '*':
                      tableName = row[0][1:]
                    else:
                        {
                            'Org': lambda row: cur.callproc('InsertOrUpdateOrg', (row[0], row[1], row[2])),
                            'Meet': lambda row: cur.callproc('InsertMeet', (row[0], row[1], row[2], row[3])),
                            'Participant': lambda row: cur.callproc('InsertOrUpdateParticipant', (row[0], row[1], row[2], row[3])),
                            'Leg': lambda row: cur.callproc('InsertLeg', (row[0],)),
                            'Stroke': lambda row: cur.callproc('InsertStroke', (row[0],)),
                            'Distance': lambda row: cur.callproc('InsertDistance', (row[0],)),
                            'Event': lambda row: cur.callproc('InsertOrUpdateEvent', (row[0], row[1], row[2])),
                            'StrokeOf': lambda row: cur.callproc('InsertStrokeOf', (row[0], row[1], row[2])),
                            'Heat': lambda row: cur.callproc('InsertHeat', (row[0], row[1],row[2])),
                            'Swim': lambda row: cur.callproc('InsertSwim', (row[0], row[1], row[2], row[3], row[4], row[5]))
                        }[tableName](row)
            conn.commit()
            messagebox.showinfo('Done', 'Imported all data from CSV file')
        except:
            conn.rollback()
            messagebox.showinfo('Alert', 'Cannot read file. Please check your filepath')

    def writeData(self, writeInput):
        try:
            with open(writeInput.get(), 'w', newline='') as f:
                writer = csv.writer(f, delimiter=',')
                # write table_org
                writer.writerow(['*Org'] + ['', '', '', '', ''])
                cur.execute('select * from org;')
                for row in cur.fetchall():
                    row = row + ('', '', '')
                    writer.writerow(row[i] for i in range(6))
                # write table_meet
                writer.writerow(['*Meet'] + ['', '', '', '', ''])
                cur.execute('select * from meet;')
                for row in cur.fetchall():
                    row = row + ('', '')
                    writer.writerow(row[i] for i in range(6))
                # write table_participant
                writer.writerow(['*Participant'] + ['', '', '', '', ''])
                cur.execute('select * from participant;')
                for row in cur.fetchall():
                    row = row + ('', '')
                    writer.writerow(row[i] for i in range(6))
                # write table_leg
                writer.writerow(['*Leg'] + ['', '', '', '', ''])
                cur.execute('select * from leg;')
                for row in cur.fetchall():
                    row = row + ('', '', '', '', '')
                    writer.writerow(row[i] for i in range(6))
                # write table_leg
                writer.writerow(['*Stroke'] + ['', '', '', '', ''])
                cur.execute('select * from stroke;')
                for row in cur.fetchall():
                    row = row + ('', '', '', '', '')
                    writer.writerow(row[i] for i in range(6))
                # write table_distance
                writer.writerow(['*Distance'] + ['', '', '', '', ''])
                cur.execute('select * from distance;')
                for row in cur.fetchall():
                    row = row + ('', '', '', '', '')
                    writer.writerow(row[i] for i in range(6))
                # write table_event
                writer.writerow(['*Event'] + ['', '', '', '', ''])
                cur.execute('select * from event;')
                for row in cur.fetchall():
                    row = row + ('', '', '')
                    writer.writerow(row[i] for i in range(6))
                # write table_strokeOf
                writer.writerow(['*StrokeOf'] + ['', '', '', '', ''])
                cur.execute('select * from strokeof;')
                for row in cur.fetchall():
                    row = row + ('', '', '')
                    writer.writerow(row[i] for i in range(6))
                # write table_heat
                writer.writerow(['*Heat'] + ['', '', '', '', ''])
                cur.execute('select * from heat;')
                for row in cur.fetchall():
                    row = row + ('', '', '')
                    writer.writerow(row[i] for i in range(6))
                # write table_swim
                writer.writerow(['*Swim,,,,,'] + ['', '', '', '', ''])
                cur.execute('select * from swim;')
                for row in cur.fetchall():
                    writer.writerow(row[i] for i in range(6))

                messagebox.showinfo('Done', 'Exported all data to CSV file')
        except:
            conn.rollback()
            messagebox.showinfo('Alert', 'Cannot read file. Please check your filepath')

    def upsertData(self, v):
        if v == 'initial string':
            return
        top = Toplevel()
        top.config(padx=10, pady=10)
        top.title('Upsert New Data to ' + v)
        Label(top, text='Input values as expected:').grid(row=0, column=0, columnspan=2, sticky='W')
        {
            'Org': lambda: self.upsertOrgTop(top),
            'Meet': lambda: self.upsertMeetTop(top),
            'Participant': lambda: self.upsertParticipantTop(top),
            'Leg': lambda: self.upsertLegTop(top),
            'Stroke': lambda: self.upsertStrokeTop(top),
            'Distance': lambda: self.upsertDistanceTop(top),
            'Event': lambda: self.upsertEventTop(top),
            'StrokeOf': lambda: self.upsertStrokeOfTop(top),
            'Heat': lambda: self.upsertHeatTop(top),
            'Swim': lambda: self.upsertSwimTop(top)
        }[v]()

    # Upsert Org
    def upsertOrgTop(self, top):
        Label(top, text=' (primary key: id) ').grid(row=0, column=2)
        Label(top, text='id(char(4))').grid(row=1, column=0, sticky='E')
        id = Entry(top, width=10)
        id.grid(row=1, column=1, sticky='W')
        Label(top, text='name(varchar(50))').grid(row=1, column=2, sticky='E')
        name = Entry(top, width=10)
        name.grid(row=1, column=3, sticky='W')
        Label(top, text='is_univ(boolean)').grid(row=2, column=0, sticky='E')
        is_univ = Entry(top, width=10)
        is_univ.grid(row=2, column=1, sticky='W')
        Button(top, text='Upsert', command=lambda: self.upsertOrg(id.get(), name.get(), is_univ.get(), top))\
            .grid(row=3, column=1, columnspan=2)

    def upsertOrg(self, id, name, is_univ, top):
        try:
            cur.callproc('InsertOrUpdateOrg', (id, name, is_univ))
            conn.commit()
            top.destroy()
        except:
            conn.rollback()
            messagebox.showinfo('Alert', 'Cannot upsert data. Please check your input')


    # Upsert Meet
    def upsertMeetTop(self, top):
        Label(top, text=' (primary key: name) ').grid(row=0, column=2)
        Label(top, text='name(varchar(50))').grid(row=1, column=0, sticky='E')
        name = Entry(top, width=10)
        name.grid(row=1, column=1, sticky='W')
        Label(top, text='start_date(date)').grid(row=1, column=2, sticky='E')
        start_date = Entry(top, width=10)
        start_date.grid(row=1, column=3, sticky='W')
        Label(top, text='num_days(int)').grid(row=2, column=0, sticky='E')
        num_days = Entry(top, width=10)
        num_days.grid(row=2, column=1, sticky='W')
        Label(top, text='org_id(int)').grid(row=2, column=2, sticky='E')
        org_id = Entry(top, width=10)
        org_id.grid(row=2, column=3, sticky='W')
        Button(top, text='Upsert', command=lambda: self.upsertMeet(name.get(), start_date.get(), num_days.get(), org_id.get(), top)) \
          .grid(row=3, column=1, columnspan=2)

    def upsertMeet(self, name, start_date, num_days, org_id, top):
        try:
            cur.callproc('InsertMeet', (name, start_date, num_days, org_id))
            conn.commit()
            top.destroy()
        except:
            conn.rollback()
            messagebox.showinfo('Alert', 'Cannot upsert data. Please check your input')

    # Upsert Participant
    def upsertParticipantTop(self, top):
        Label(top, text=' (primary key: id) ').grid(row=0, column=2)
        Label(top, text='id(char(7))').grid(row=1, column=0, sticky='E')
        id = Entry(top, width=10)
        id.grid(row=1, column=1, sticky='W')
        Label(top, text='gender(char(1))').grid(row=1, column=2, sticky='E')
        gender = Entry(top, width=10)
        gender.grid(row=1, column=3, sticky='W')
        Label(top, text='org_id(char(4))').grid(row=2, column=0, sticky='E')
        org_id = Entry(top, width=10)
        org_id.grid(row=2, column=1, sticky='W')
        Label(top, text='first_name(varchar(20))').grid(row=2, column=2, sticky='E')
        first_name = Entry(top, width=10)
        first_name.grid(row=2, column=3, sticky='W')
        Button(top, text='Upsert', command=lambda: self.upsertParticipant(id.get(), gender.get(), org_id.get(), first_name.get(), top)) \
            .grid(row=3, column=1, columnspan=2)

    def upsertParticipant(self, id, gender, org_id, first_name, top):
        try:
            cur.callproc('InsertOrUpdateParticipant', (id, gender, org_id, first_name))
            conn.commit()
            top.destroy()
        except:
            conn.rollback()
            messagebox.showinfo('Alert', 'Cannot upsert data. Please check your input')

    # Upsert Leg
    def upsertLegTop(self, top):
        Label(top, text=' (primary key: leg) ').grid(row=0, column=2)
        Label(top, text='leg(int)').grid(row=1, column=0, sticky='E')
        leg = Entry(top, width=10)
        leg.grid(row=1, column=1, sticky='W')
        Button(top, text='Upsert',
               command=lambda: self.upsertLeg(leg.get(), top)) \
            .grid(row=2, column=1, columnspan=2)

    def upsertLeg(self, leg, top):
        try:
            cur.callproc('InsertLeg', (leg,))
            conn.commit()
            top.destroy()
        except:
            conn.rollback()
            messagebox.showinfo('Alert', 'Cannot upsert data. Please check your input')

    # Upsert Stroke
    def upsertStrokeTop(self, top):
        Label(top, text=' (primary key: stroke) ').grid(row=0, column=2)
        Label(top, text='stroke(varchar(20))').grid(row=1, column=0, sticky='E')
        stroke = Entry(top, width=10)
        stroke.grid(row=1, column=1, sticky='W')
        Button(top, text='Upsert',
               command=lambda: self.upsertStroke(stroke.get(), top)) \
            .grid(row=2, column=1, columnspan=2)

    def upsertStroke(self, stroke, top):
        try:
            cur.callproc('InsertStroke', (stroke,))
            conn.commit()
            top.destroy()
        except:
            conn.rollback()
            messagebox.showinfo('Alert', 'Cannot upsert data. Please check your input')

    #Upsert Distance
    def upsertDistanceTop(self, top):
        Label(top, text=' (primary key: distance) ').grid(row=0, column=2)
        Label(top, text='distance(int)').grid(row=1, column=0, sticky='E')
        distance = Entry(top, width=10)
        distance.grid(row=1, column=1, sticky='W')
        Button(top, text='Upsert',
               command=lambda: self.upsertDistance(distance.get(), top)) \
            .grid(row=2, column=1, columnspan=2)

    def upsertDistance(self, distance, top):
        try:
            cur.callproc('InsertDistance', (distance,))
            conn.commit()
            top.destroy()
        except:
            conn.rollback()
            messagebox.showinfo('Alert', 'Cannot upsert data. Please check your input')

    # Upsert Event
    def upsertEventTop(self, top):
        Label(top, text=' (primary key: id) ').grid(row=0, column=2)
        Label(top, text='id(char(5))').grid(row=1, column=0, sticky='E')
        id = Entry(top, width=10)
        id.grid(row=1, column=1, sticky='W')
        Label(top, text='gender(char(1))').grid(row=1, column=2, sticky='E')
        gender = Entry(top, width=10)
        gender.grid(row=1, column=3, sticky='W')
        Label(top, text='distance(int)').grid(row=2, column=0, sticky='E')
        distance = Entry(top, width=10)
        distance.grid(row=2, column=1, sticky='W')
        Button(top, text='Upsert', command=lambda: self.upsertEvent(id.get(), gender.get(), distance.get(), top))\
            .grid(row=3, column=1, columnspan=2)

    def upsertEvent(self, id, gender, distance, top):
        try:
            cur.callproc('InsertOrUpdateEvent', (id, gender, distance))
            conn.commit()
            top.destroy()
        except:
            conn.rollback()
            messagebox.showinfo('Alert', 'Cannot upsert data. Please check your input')

    # Upsert StrokeOf
    def upsertStrokeOfTop(self, top):
        Label(top, text=' (primary key: event_id, leg) ').grid(row=0, column=2)
        Label(top, text='event_id(char(5))').grid(row=1, column=0, sticky='E')
        event_id = Entry(top, width=10)
        event_id.grid(row=1, column=1, sticky='W')
        Label(top, text='leg(int)').grid(row=1, column=2, sticky='E')
        leg = Entry(top, width=10)
        leg.grid(row=1, column=3, sticky='W')
        Label(top, text='stroke(varchar(20))').grid(row=2, column=0, sticky='E')
        stroke = Entry(top, width=10)
        stroke.grid(row=2, column=1, sticky='W')
        Button(top, text='Upsert', command=lambda: self.upsertStrokeOf(event_id.get(), leg.get(), stroke.get(), top))\
            .grid(row=3, column=1, columnspan=2)

    def upsertStrokeOf(self, event_id, leg, stroke, top):
        try:
            cur.callproc('InsertStrokeOf', (event_id, leg, stroke))
            conn.commit()
            top.destroy()
        except:
            conn.rollback()
            messagebox.showinfo('Alert', 'Cannot upsert data. Please check your input')

    # Upsert Heat
    def upsertHeatTop(self, top):
        Label(top, text=' (primary key: id, event_id, meet_name) ').grid(row=0, column=2)
        Label(top, text='id(int)').grid(row=1, column=0, sticky='E')
        id = Entry(top, width=10)
        id.grid(row=1, column=1, sticky='W')
        Label(top, text='event_id(char(5))').grid(row=1, column=2, sticky='E')
        event_id = Entry(top, width=10)
        event_id.grid(row=1, column=3, sticky='W')
        Label(top, text='meet_name(varchar(50))').grid(row=2, column=0, sticky='E')
        meet_name = Entry(top, width=10)
        meet_name.grid(row=2, column=1, sticky='W')
        Button(top, text='Upsert', command=lambda: self.upsertHeat(id.get(), event_id.get(), meet_name.get(), top)) \
            .grid(row=3, column=1, columnspan=2)

    def upsertHeat(self, id, event_id, meet_name, top):
        try:
            cur.callproc('InsertHeat', (id, event_id, meet_name))
            conn.commit()
            top.destroy()
        except:
            conn.rollback()
            messagebox.showinfo('Alert', 'Cannot upsert data. Please check your input')

    # Upsert Swim
    def upsertSwimTop(self, top):
        Label(top, text=' (primary key: heat_id, event_id, meet_name, participant_id) ').grid(row=0, column=2, columnspan=2)
        Label(top, text='heat_id(int)').grid(row=1, column=0, sticky='E')
        heat_id = Entry(top, width=10)
        heat_id.grid(row=1, column=1, sticky='W')
        Label(top, text='event_id(char(5))').grid(row=1, column=2, sticky='E')
        event_id = Entry(top, width=10)
        event_id.grid(row=1, column=3, sticky='W')
        Label(top, text='meet_name(varchar(50))').grid(row=2, column=0, sticky='E')
        meet_name = Entry(top, width=10)
        meet_name.grid(row=2, column=1, sticky='W')
        Label(top, text='participant_id(char(7))').grid(row=2, column=2, sticky='E')
        participant_id = Entry(top, width=10)
        participant_id.grid(row=2, column=3, sticky='W')
        Label(top, text='leg(int)').grid(row=3, column=0, sticky='E')
        leg = Entry(top, width=10)
        leg.grid(row=3, column=1, sticky='W')
        Label(top, text='time(numeric)').grid(row=3, column=2, sticky='E')
        time = Entry(top, width=10)
        time.grid(row=3, column=3, sticky='W')

        Button(top, text='Upsert',
               command=lambda: self.upsertSwim(heat_id.get(), event_id.get(), meet_name.get(),
                                               participant_id.get(),leg.get(), time.get(), top))\
            .grid(row=4, column=1, columnspan=2)

    def upsertSwim(self, heat_id, event_id, meet_name, participant_id, leg, time, top):
        try:
            cur.callproc('InsertSwim', (heat_id, event_id, meet_name, participant_id, leg, time))
            conn.commit()
            top.destroy()
        except:
            conn.rollback()
            messagebox.showinfo('Alert', 'Cannot upsert data. Please check your input')

    def display(self, *arg):
        try:
            top = Toplevel()
            top.config(padx=10, pady=10)
            if arg[0] == 'M2H':
                cur.callproc('MeetToHeatSheet', (arg[1],))
                top.title('Heat Sheet for ' + arg[1])
                tree = Treeview(top, show='headings', height=20, columns=('a', 'b', 'c', 'd', 'e', 'f', 'g'))
                tree.column('a', width=60, anchor='center')
                tree.column('b', width=50, anchor='center')
                tree.column('c', width=120, anchor='center')
                tree.column('d', width=120, anchor='center')
                tree.column('e', width=120, anchor='center')
                tree.column('f', width=120, anchor='center')
                tree.column('g', width=50, anchor="center")
                tree.heading('a', text='Event Id')
                tree.heading('b', text='Heat Id')
                tree.heading('c', text='Participant Id')
                tree.heading('d', text='Organization Name')
                tree.heading('e', text='Individual Time')
                tree.heading('f', text='Relay Time')
                tree.heading('g', text='Rank')
            elif arg[0] == 'PM2H':
                print(arg[1])
                print(arg[2])
                cur.callproc('ParticipantMeetToHeatSheet', (arg[1], arg[2]))
                tree = Treeview(top, show='headings', height=20, columns=('a', 'b', 'c', 'd', 'e', 'f'))
                top.title('Heat Sheet for Participant_Id ' + arg[1] + ' and ' + arg[2])
                tree.column('a', width=60, anchor='center')
                tree.column('b', width=50, anchor='center')
                tree.column('c', width=120, anchor='center')
                tree.column('d', width=120, anchor='center')
                tree.column('e', width=120, anchor='center')
                tree.column('f', width=50, anchor="center")
                tree.heading('a', text='Event Id')
                tree.heading('b', text='Heat Id')
                tree.heading('c', text='Organization Name')
                tree.heading('d', text='Individual Time')
                tree.heading('e', text='Relay Time')
                tree.heading('f', text='Rank')
            elif arg[0] == 'OM2H':
                cur.callproc('OrgMeetToHeatSheet', (arg[1], arg[2]))
                tree = Treeview(top, show='headings', height=20, columns=('a', 'b', 'c', 'd', 'e', 'f'))
                top.title('Heat Sheet of Org_Id ' + arg[1] + ' for ' + arg[2])
                tree.column('a', width=60, anchor='center')
                tree.column('b', width=50, anchor='center')
                tree.column('c', width=120, anchor='center')
                tree.column('d', width=120, anchor='center')
                tree.column('e', width=120, anchor='center')
                tree.column('f', width=50, anchor="center")
                tree.heading('a', text='Event Id')
                tree.heading('b', text='Heat Id')
                tree.heading('c', text='Participant Id')
                tree.heading('d', text='Individual Time')
                tree.heading('e', text='Relay Time')
                tree.heading('f', text='Rank')
            elif arg[0] == 'OM2S':
                cur.callproc('OrgMeetToSwimmerName', (arg[1], arg[2]))
                tree = Treeview(top, show='headings', height=20, columns=('a',))
                top.title('Names of Swimmers of Org_Id ' + arg[1] + ' for ' + arg[2])
                tree.column('a', width=100, anchor='center')
                tree.heading('a', text='Participant Name')
            elif arg[0] == 'EM2H':
                cur.callproc('EventMeetToHeatSheet', (arg[1], arg[2]))
                tree = Treeview(top, show='headings', height=20, columns=('a', 'b', 'c', 'd', 'e', 'f', 'g'))
                top.title('Heat Sheet for ' + arg[1] + ' and ' + arg[2])
                tree.column('a', width=50, anchor='center')
                tree.column('b', width=120, anchor='center')
                tree.column('c', width=120, anchor='center')
                tree.column('d', width=120, anchor='center')
                tree.column('e', width=120, anchor='center')
                tree.column('f', width=120, anchor='center')
                tree.column('g', width=50, anchor="center")
                tree.heading('a', text='Heat Id')
                tree.heading('b', text='Participant Id')
                tree.heading('c', text='Participant Name')
                tree.heading('d', text='Org Name')
                tree.heading('e', text='Individual Time')
                tree.heading('f', text='Relay Time')
                tree.heading('g', text='Rank')
            elif arg[0] == 'M2S':
                cur.callproc('MeetOrgToScore', (arg[1],))
                tree = Treeview(top, show='headings', columns=('a', 'b', 'c'))
                top.title('Scores of each school for ' + arg[1])
                tree.column('a', width=50, anchor='center')
                tree.column('b', width=120, anchor='center')
                tree.column('c', width=120, anchor='center')
                tree.heading('a', text='Org Id')
                tree.heading('b', text='Org Name')
                tree.heading('c', text='Scores')
            vbar = Scrollbar(top, orient=VERTICAL, command=tree.yview)
            tree.configure(yscrollcommand=vbar.set)
            rows = cur.fetchall()
            for i in range(len(rows)):
                tree.insert('', 'end', values=[j for j in rows[i]])
            tree.grid(row=0, column=0, sticky=NSEW)
            vbar.grid(row=0, column=1, sticky=NS)

        except:
            conn.rollback()
            return

app = Application()
app.master.title('Comp533 Project Database Management Application')
# app.master.minsize(width=550, height=500)
app.master.maxsize(width=550, height=700)
app.mainloop()

# Make the changes to the database persistent
conn.commit()

# Close communication with the database
cur.close()

conn.close()
